'use strict';
var vscode = require('vscode');
var path_1 = require('path');
var os = require('os');
var fs = require('fs');
var appInsightsClient_1 = require('./appInsightsClient');
var TmpDir = os.tmpdir();
var CodeManager = (function () {
    function CodeManager() {
        this._outputChannel = vscode.window.createOutputChannel('Code');
        this._terminal = null;
        this._appInsightsClient = new appInsightsClient_1.AppInsightsClient();
    }
    CodeManager.prototype.onDidCloseTerminal = function () {
        this._terminal = null;
    };
    CodeManager.prototype.run = function (languageId) {
        if (languageId === void 0) { languageId = null; }
        if (this._isRunning) {
            vscode.window.showInformationMessage('Code is already running!');
            return;
        }
        var editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showInformationMessage('No code found or selected.');
            return;
        }
        this.initialize(editor);
        var fileExtension = this.getFileExtension(editor);
        var executor = this.getExecutor(languageId, fileExtension);
        // undefined or null
        if (executor == null) {
            vscode.window.showInformationMessage('Code language not supported or defined.');
            return;
        }
        this.getCodeFileAndExecute(editor, fileExtension, executor);
    };
    CodeManager.prototype.runCustomCommand = function () {
        if (this._isRunning) {
            vscode.window.showInformationMessage('Code is already running!');
            return;
        }
        var editor = vscode.window.activeTextEditor;
        this.initialize(editor);
        var executor = this._config.get('customCommand');
        if (editor) {
            var fileExtension = this.getFileExtension(editor);
            this.getCodeFileAndExecute(editor, fileExtension, executor, false);
        }
        else {
            this.executeCommand(executor, false);
        }
    };
    CodeManager.prototype.runByLanguage = function () {
        var _this = this;
        this._appInsightsClient.sendEvent('runByLanguage');
        var config = vscode.workspace.getConfiguration('code-runner');
        var executorMap = config.get('executorMap');
        vscode.window.showQuickPick(Object.keys(executorMap), { placeHolder: "Type or select language to run" }).then(function (languageId) {
            if (languageId !== undefined) {
                _this.run(languageId);
            }
        });
    };
    CodeManager.prototype.stop = function () {
        this._appInsightsClient.sendEvent('stop');
        if (this._isRunning) {
            this._isRunning = false;
            var kill = require('tree-kill');
            kill(this._process.pid);
        }
    };
    CodeManager.prototype.initialize = function (editor) {
        this._config = vscode.workspace.getConfiguration('code-runner');
        this._cwd = this._config.get('cwd');
        if (this._cwd) {
            return;
        }
        if (this._config.get('fileDirectoryAsCwd') && editor && !editor.document.isUntitled) {
            this._cwd = path_1.dirname(editor.document.fileName);
        }
        else {
            this._cwd = vscode.workspace.rootPath;
        }
        if (this._cwd) {
            return;
        }
        this._cwd = TmpDir;
    };
    CodeManager.prototype.getCodeFileAndExecute = function (editor, fileExtension, executor, appendFile) {
        var _this = this;
        if (appendFile === void 0) { appendFile = true; }
        var selection = editor.selection;
        if (selection.isEmpty && !editor.document.isUntitled) {
            this._isTmpFile = false;
            this._codeFile = editor.document.fileName;
            if (this._config.get('saveFileBeforeRun')) {
                return editor.document.save().then(function () {
                    _this.executeCommand(executor, appendFile);
                });
            }
        }
        else {
            var text = selection.isEmpty ? editor.document.getText() : editor.document.getText(selection);
            if (this._languageId === "php") {
                text = text.trim();
                if (!text.startsWith("<?php")) {
                    text = "<?php\r\n" + text;
                }
            }
            this._isTmpFile = true;
            var folder = editor.document.isUntitled ? this._cwd : path_1.dirname(editor.document.fileName);
            this.createRandomFile(text, folder, fileExtension);
        }
        this.executeCommand(executor, appendFile);
    };
    CodeManager.prototype.rndName = function () {
        return Math.random().toString(36).replace(/[^a-z]+/g, '').substr(0, 10);
    };
    CodeManager.prototype.createRandomFile = function (content, folder, fileExtension) {
        var fileType = "";
        var languageIdToFileExtensionMap = this._config.get('languageIdToFileExtensionMap');
        if (this._languageId && languageIdToFileExtensionMap[this._languageId]) {
            fileType = languageIdToFileExtensionMap[this._languageId];
        }
        else {
            if (fileExtension) {
                fileType = fileExtension;
            }
            else {
                fileType = '.' + this._languageId;
            }
        }
        var tmpFileName = 'temp-' + this.rndName() + fileType;
        this._codeFile = path_1.join(folder, tmpFileName);
        fs.writeFileSync(this._codeFile, content);
    };
    CodeManager.prototype.getExecutor = function (languageId, fileExtension) {
        this._languageId = languageId === null ? vscode.window.activeTextEditor.document.languageId : languageId;
        var executorMap = this._config.get('executorMap');
        var executor = executorMap[this._languageId];
        // executor is undefined or null
        if (executor == null && fileExtension) {
            var executorMapByFileExtension = this._config.get('executorMapByFileExtension');
            executor = executorMapByFileExtension[fileExtension];
            if (executor != null) {
                this._languageId = fileExtension;
            }
        }
        if (executor == null) {
            this._languageId = this._config.get('defaultLanguage');
            executor = executorMap[this._languageId];
        }
        return executor;
    };
    CodeManager.prototype.getFileExtension = function (editor) {
        var fileName = editor.document.fileName;
        var index = fileName.lastIndexOf(".");
        if (index !== -1) {
            return fileName.substr(index);
        }
        else {
            return "";
        }
    };
    CodeManager.prototype.executeCommand = function (executor, appendFile) {
        if (appendFile === void 0) { appendFile = true; }
        if (this._config.get('runInTerminal') && !this._isTmpFile) {
            this.executeCommandInTerminal(executor, appendFile);
        }
        else {
            this.executeCommandInOutputChannel(executor, appendFile);
        }
    };
    CodeManager.prototype.getWorkspaceRoot = function (codeFileDir) {
        return vscode.workspace.rootPath ? vscode.workspace.rootPath : codeFileDir;
    };
    /**
     * Gets the base name of the code file, that is without its directory.
     */
    CodeManager.prototype.getCodeBaseFile = function () {
        var regexMatch = this._codeFile.match(/.*[\/\\](.*)/);
        return regexMatch.length ? regexMatch[1] : this._codeFile;
    };
    /**
     * Gets the code file name without its directory and extension.
     */
    CodeManager.prototype.getCodeFileWithoutDirAndExt = function () {
        var regexMatch = this._codeFile.match(/.*[\/\\](.*(?=\..*))/);
        return regexMatch.length ? regexMatch[1] : this._codeFile;
    };
    /**
     * Gets the directory of the code file.
     */
    CodeManager.prototype.getCodeFileDir = function () {
        var regexMatch = this._codeFile.match(/(.*[\/\\]).*/);
        return regexMatch.length ? regexMatch[1] : this._codeFile;
    };
    /**
     * Includes double quotes around a given file name.
     */
    CodeManager.prototype.quoteFileName = function (fileName) {
        return '\"' + fileName + '\"';
    };
    /**
     * Gets the executor to run a source code file
     * and generates the complete command that allow that file to be run.
     * This executor command may include a variable $1 to indicate the place where
     * the source code file name have to be included.
     * If no such a variable is present in the executor command,
     * the file name is appended to the end of the executor command.
     *
     * @param executor The command used to run a source code file
     * @return the complete command to run the file, that includes the file name
     */
    CodeManager.prototype.getFinalCommandToRunCodeFile = function (executor, appendFile) {
        if (appendFile === void 0) { appendFile = true; }
        var cmd = executor;
        if (this._codeFile) {
            var codeFileDir = this.getCodeFileDir();
            var placeholders = [
                //A placeholder that has to be replaced by the path of the folder opened in VS Code
                //If no folder is opened, replace with the directory of the code file
                { "regex": /\$workspaceRoot/g, "replaceValue": this.getWorkspaceRoot(codeFileDir) },
                //A placeholder that has to be replaced by the code file name without its extension
                { "regex": /\$fileNameWithoutExt/g, "replaceValue": this.getCodeFileWithoutDirAndExt() },
                //A placeholder that has to be replaced by the full code file name
                { "regex": /\$fullFileName/g, "replaceValue": this.quoteFileName(this._codeFile) },
                //A placeholder that has to be replaced by the code file name without the directory
                { "regex": /\$fileName/g, "replaceValue": this.getCodeBaseFile() },
                //A placeholder that has to be replaced by the directory of the code file
                { "regex": /\$dir/g, "replaceValue": this.quoteFileName(codeFileDir) }
            ];
            placeholders.forEach(function (placeholder) {
                cmd = cmd.replace(placeholder.regex, placeholder.replaceValue);
            });
        }
        return (cmd != executor ? cmd : executor + (appendFile ? ' ' + this.quoteFileName(this._codeFile) : ''));
    };
    CodeManager.prototype.executeCommandInTerminal = function (executor, appendFile) {
        if (appendFile === void 0) { appendFile = true; }
        if (this._terminal === null) {
            this._terminal = vscode.window.createTerminal('Code');
        }
        this._terminal.show(true);
        var command = this.getFinalCommandToRunCodeFile(executor, appendFile);
        this._terminal.sendText(command);
    };
    CodeManager.prototype.executeCommandInOutputChannel = function (executor, appendFile) {
        var _this = this;
        if (appendFile === void 0) { appendFile = true; }
        this._isRunning = true;
        var clearPreviousOutput = this._config.get('clearPreviousOutput');
        if (clearPreviousOutput) {
            this._outputChannel.clear();
        }
        var showExecutionMessage = this._config.get('showExecutionMessage');
        this._outputChannel.show(true);
        var exec = require('child_process').exec;
        var command = this.getFinalCommandToRunCodeFile(executor, appendFile);
        if (showExecutionMessage) {
            this._outputChannel.appendLine('[Running] ' + command);
        }
        this._appInsightsClient.sendEvent(executor);
        var startTime = new Date();
        this._process = exec(command, { cwd: this._cwd });
        this._process.stdout.on('data', function (data) {
            _this._outputChannel.append(data);
        });
        this._process.stderr.on('data', function (data) {
            _this._outputChannel.append(data);
        });
        this._process.on('close', function (code) {
            _this._isRunning = false;
            var endTime = new Date();
            var elapsedTime = (endTime.getTime() - startTime.getTime()) / 1000;
            _this._outputChannel.appendLine('');
            if (showExecutionMessage) {
                _this._outputChannel.appendLine('[Done] exited with code=' + code + ' in ' + elapsedTime + ' seconds');
                _this._outputChannel.appendLine('');
            }
            if (_this._isTmpFile) {
                fs.unlink(_this._codeFile);
            }
        });
    };
    return CodeManager;
}());
exports.CodeManager = CodeManager;
//# sourceMappingURL=codeManager.js.map