"use strict";
const vscode = require('vscode');
function promptForPort() {
    var opt = {
        prompt: 'What port does your app listen on?',
        value: '3000',
        placeHolder: '3000'
    };
    return vscode.window.showInputBox(opt);
}
exports.promptForPort = promptForPort;
function quickPickPlatform() {
    var opt = {
        matchOnDescription: true,
        matchOnDetail: true
    };
    var items = [];
    items.push('nodejs');
    items.push('go');
    items.push('.NET Core');
    items.push('Other');
    return vscode.window.showQuickPick(items, opt);
}
exports.quickPickPlatform = quickPickPlatform;
//# sourceMappingURL=config-prompts.js.map