"use strict";
const vscode = require('vscode');
const quick_pick_image_1 = require('./utils/quick-pick-image');
function pushImage() {
    quick_pick_image_1.quickPickImage(false).then(function (selectedItem) {
        if (selectedItem) {
            let terminal = vscode.window.createTerminal(selectedItem.label);
            terminal.sendText(`docker push ${selectedItem.label}`);
            terminal.show();
        }
        ;
    });
}
exports.pushImage = pushImage;
//# sourceMappingURL=push-image.js.map