'use strict';
var vscode = require('vscode');
var appInsights = require("applicationinsights");
var compilers = ['gcc', 'g++', 'javac'];
var AppInsightsClient = (function () {
    function AppInsightsClient() {
        this._client = appInsights.getClient('a25ddf11-20fc-45c6-96ae-524f47754f28');
        var config = vscode.workspace.getConfiguration('code-runner');
        this._enableAppInsights = config.get('enableAppInsights');
    }
    AppInsightsClient.prototype.sendEvent = function (eventName) {
        if (this._enableAppInsights) {
            for (var i in compilers) {
                if (eventName.indexOf(compilers[i] + ' ') >= 0) {
                    eventName = compilers[i];
                    break;
                }
            }
            this._client.trackEvent(eventName === '' ? 'bat' : eventName);
        }
    };
    return AppInsightsClient;
}());
exports.AppInsightsClient = AppInsightsClient;
//# sourceMappingURL=appInsightsClient.js.map