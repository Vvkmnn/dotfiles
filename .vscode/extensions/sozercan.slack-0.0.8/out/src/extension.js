var vscode = require('vscode');
var request = require('request');
var fs = require('fs');
var channelList = [];
var configuration = vscode.workspace.getConfiguration('slack');
var teamToken = configuration.get('teamToken');
var username = configuration.get('username');
var avatarUrl = configuration.get('avatarUrl');
var BASE_URL = 'https://slack.com/api/';
var API_CHANNELS = 'channels.list';
var API_USERS = 'users.list';
var API_GROUPS = 'groups.list';
var API_POST_MESSAGE = 'chat.postMessage';
var API_UPLOAD_FILES = 'files.upload';
var API_SET_SNOOZE = 'dnd.setSnooze';
var API_END_SNOOZE = 'dnd.endSnooze';
var Slack = (function () {
    function Slack() {
    }
    Slack.prototype.GetChannelList = function (callback, type, data) {
        var params = '?token=' + teamToken + '&exclude_archived=1';
        channelList.length = 0;
        var __request = function (urls, callback) {
            var results = {}, t = urls.length, c = 0, handler = function (error, response, body) {
                var url = response.request.uri.href;
                results[url] = { error: error, response: response, body: body };
                if (++c === urls.length) {
                    callback(results);
                }
            };
            while (t--) {
                request(urls[t], handler);
            }
        };
        var urls = [BASE_URL + API_CHANNELS + params, BASE_URL + API_GROUPS + params, BASE_URL + API_USERS + params];
        __request(urls, function (responses) {
            var url, response;
            for (url in responses) {
                // reference to the response object
                response = responses[url];
                // find errors
                if (response.error) {
                    console.log("Error", url, response.error);
                    return;
                }
                // render body
                if (response.body) {
                    var r = JSON.parse(response.body);
                    if (r.channels) {
                        for (var i = 0; i < r.channels.length; i++) {
                            var c = r.channels[i];
                            channelList.push({ id: c.id, label: '#' + c.name });
                        }
                    }
                    if (r.groups) {
                        for (var i = 0; i < r.groups.length; i++) {
                            var c = r.groups[i];
                            channelList.push({ id: c.id, label: '#' + c.name, description: c.topic.value });
                        }
                    }
                    if (r.members) {
                        for (var i = 0; i < r.members.length; i++) {
                            var c = r.members[i];
                            channelList.push({ id: c.id, label: '@' + c.name, description: c.profile.real_name });
                        }
                    }
                }
            }
            callback && callback(type, data);
        });
    };
    Slack.prototype.ApiCall = function (apiType, data) {
        var that = this;
        if (!this._statusBarItem) {
            this._statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left);
        }
        request.post({
            url: BASE_URL + apiType,
            formData: data
        }, function (error, response, body) {
            if (!error && response.statusCode == 200) {
                switch (apiType) {
                    case API_SET_SNOOZE:
                    case API_END_SNOOZE:
                        that._statusBarItem.text = "$(bell) Status set successfully!";
                        break;
                    case API_UPLOAD_FILES:
                        that._statusBarItem.text = "$(file-text) File sent successfully!";
                        break;
                    default:
                        that._statusBarItem.text = "$(comment) Message sent successfully!";
                        break;
                }
                that._statusBarItem.show();
                setTimeout(function () { that._statusBarItem.hide(); }, 5000);
            }
        });
    };
    Slack.prototype.QuickPick = function () {
        return vscode.window.showQuickPick(channelList, { matchOnDescription: true, placeHolder: 'Select a channel' });
    };
    Slack.prototype.Send = function (type, data) {
        var sendMsg = function (type, data) {
            if (data) {
                var s = new Slack();
                s.ApiCall(type, data);
            }
        };
        // sending a message to a specified channel/user/group
        if (data.channel) {
            sendMsg(type, data);
        }
        else {
            var slack = new Slack;
            var pick = slack.QuickPick();
            pick.then(function (item) {
                if (item) {
                    data.channels = item.id;
                    data.channel = item.id;
                    sendMsg(type, data);
                }
            });
        }
    };
    // Upload file from path
    Slack.prototype.UploadFilePath = function () {
        var _this = this;
        var options = {
            prompt: "Please enter a path"
        };
        vscode.window.showInputBox(options).then(function (path) {
            if (path) {
                var data = {
                    channels: '',
                    token: teamToken,
                    file: fs.createReadStream(path)
                };
                _this.GetChannelList(_this.Send, API_UPLOAD_FILES, data);
            }
        });
    };
    // Upload current file
    Slack.prototype.UploadFileCurrent = function () {
        var document = vscode.window.activeTextEditor.document.getText();
        var data = {
            channels: '',
            token: teamToken,
            content: document
        };
        this.GetChannelList(this.Send, API_UPLOAD_FILES, data);
    };
    // Upload selection as file
    Slack.prototype.UploadFileSelection = function () {
        var editor = vscode.window.activeTextEditor;
        var selection = editor.selection;
        var document = vscode.window.activeTextEditor.document.getText(selection);
        var data = {
            channels: '',
            token: teamToken,
            content: document
        };
        this.GetChannelList(this.Send, API_UPLOAD_FILES, data);
    };
    Slack.prototype.SendMessage = function () {
        var _this = this;
        var options = {
            prompt: "Please enter a message",
            value: this.savedChannel
        };
        vscode.window.showInputBox(options).then(function (text) {
            if (text) {
                var data = {
                    channel: '',
                    token: teamToken,
                    username: username,
                    icon_url: avatarUrl,
                    text: text
                };
                if (text.startsWith("@") || text.startsWith("#")) {
                    data.channel = text.substr(0, text.indexOf(' '));
                    _this.savedChannel = data.channel + " "; // remember last used channel
                    data.text = text.substr(text.indexOf(' ') + 1);
                }
                else {
                    _this.savedChannel = ""; // clear saved channel
                }
                _this.GetChannelList(_this.Send, API_POST_MESSAGE, data);
            }
        });
    };
    ;
    Slack.prototype.SendSelection = function () {
        var editor = vscode.window.activeTextEditor;
        if (!editor) {
            return; // No open text editor
        }
        var selection = editor.selection;
        var text = '```' + editor.document.getText(selection) + '```';
        var data = {
            channel: '',
            token: teamToken,
            username: username,
            icon_url: avatarUrl,
            text: text
        };
        this.GetChannelList(this.Send, API_POST_MESSAGE, data);
    };
    Slack.prototype.SetSnooze = function () {
        var _this = this;
        var options = {
            prompt: "Please enter number of minutes"
        };
        vscode.window.showInputBox(options).then(function (num_minutes) {
            if (num_minutes) {
                var data = {
                    token: teamToken,
                    num_minutes: num_minutes
                };
                _this.ApiCall(API_SET_SNOOZE, data);
            }
        });
    };
    Slack.prototype.EndSnooze = function () {
        var data = {
            token: teamToken
        };
        this.ApiCall(API_END_SNOOZE, data);
    };
    Slack.prototype.dispose = function () {
    };
    return Slack;
})();
// this method is called when your extension is activated
// your extension is activated the very first time the command is executed
function activate(context) {
    // The command has been defined in the package.json file
    // Now provide the implementation of the command with  registerCommand
    // The commandId parameter must match the command field in package.json
    if (teamToken) {
        var slack = new Slack();
        // send typed message
        vscode.commands.registerCommand('extension.slackSendMsg', function () { return slack.SendMessage(); });
        // send selected text as a message
        vscode.commands.registerCommand('extension.slackSendSelection', function () { return slack.SendSelection(); });
        // upload current file
        vscode.commands.registerCommand('extension.slackUploadFileCurrent', function () { return slack.UploadFileCurrent(); });
        // upload selection
        vscode.commands.registerCommand('extension.slackUploadFileSelection', function () { return slack.UploadFileSelection(); });
        // upload file path
        vscode.commands.registerCommand('extension.slackUploadFilePath', function () { return slack.UploadFilePath(); });
        // snooze controls
        vscode.commands.registerCommand('extension.slackSetSnooze', function () { return slack.SetSnooze(); });
        vscode.commands.registerCommand('extension.slackEndSnooze', function () { return slack.EndSnooze(); });
        // Add to a list of disposables which are disposed when this extension is deactivated.
        context.subscriptions.push(slack);
    }
    else {
        vscode.window.showErrorMessage('Please enter a team token to use this extension.');
    }
}
exports.activate = activate;
// this method is called when your extension is deactivated
function deactivate() {
}
exports.deactivate = deactivate;
//# sourceMappingURL=extension.js.map