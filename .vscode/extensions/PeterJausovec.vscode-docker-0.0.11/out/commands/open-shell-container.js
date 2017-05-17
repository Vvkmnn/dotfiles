"use strict";
const vscode = require('vscode');
const quick_pick_container_1 = require('./utils/quick-pick-container');
function openShellContainer() {
    quick_pick_container_1.quickPickContainer().then(function (selectedItem) {
        if (selectedItem) {
            let terminal = vscode.window.createTerminal(`sh ${selectedItem.label}`);
            terminal.sendText(`docker exec -it ${selectedItem.ids[0]} /bin/sh`);
            terminal.show();
        }
    });
}
exports.openShellContainer = openShellContainer;
//# sourceMappingURL=open-shell-container.js.map