"use strict";
const vscode = require('vscode');
const quick_pick_container_1 = require('./utils/quick-pick-container');
function showLogsContainer() {
    quick_pick_container_1.quickPickContainer().then(function (selectedItem) {
        if (selectedItem) {
            let terminal = vscode.window.createTerminal(selectedItem.label);
            terminal.sendText(`docker logs -f ${selectedItem.ids[0]}`);
            terminal.show();
        }
    });
}
exports.showLogsContainer = showLogsContainer;
//# sourceMappingURL=showlogs-container.js.map