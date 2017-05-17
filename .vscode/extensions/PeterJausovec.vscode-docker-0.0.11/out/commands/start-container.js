"use strict";
const vscode = require('vscode');
const quick_pick_image_1 = require('./utils/quick-pick-image');
function doStartContainer(interactive) {
    quick_pick_image_1.quickPickImage(false).then(function (selectedItem) {
        if (selectedItem) {
            let option = interactive ? '-it' : '';
            let terminal = vscode.window.createTerminal(selectedItem.label);
            terminal.sendText(`docker run ${option} --rm ${selectedItem.label}`);
            terminal.show();
        }
    });
}
function startContainer() {
    doStartContainer(false);
}
exports.startContainer = startContainer;
function startContainerInteractive() {
    doStartContainer(true);
}
exports.startContainerInteractive = startContainerInteractive;
function startAzureCLI() {
    let terminal = vscode.window.createTerminal('Azure CLI');
    terminal.sendText(`docker run -it --rm microsoft/azure-cli:latest`);
    terminal.show();
    terminal.sendText(`azure login`);
}
exports.startAzureCLI = startAzureCLI;
//# sourceMappingURL=start-container.js.map