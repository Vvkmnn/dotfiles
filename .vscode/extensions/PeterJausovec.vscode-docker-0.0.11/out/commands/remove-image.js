"use strict";
const docker_endpoint_1 = require('./utils/docker-endpoint');
const quick_pick_image_1 = require('./utils/quick-pick-image');
const vscode = require('vscode');
function removeImage() {
    quick_pick_image_1.quickPickImage(true).then(function (selectedItem) {
        if (selectedItem) {
            // if we're removing all images, remove duplicate IDs, a result of tagging
            if (selectedItem.label.toLowerCase().includes('all images')) {
                selectedItem.ids = Array.from(new Set(selectedItem.ids));
            }
            for (let i = 0; i < selectedItem.ids.length; i++) {
                let image = docker_endpoint_1.docker.getImage(selectedItem.ids[i]);
                // image.remove removes by ID, so to remove a single *tagged* image we
                // just overwrite the name. this is a hack around the dockerode api
                if (selectedItem.ids.length === 1) {
                    if (!selectedItem.label.toLowerCase().includes('<none>')) {
                        image.name = selectedItem.label;
                    }
                }
                image.remove({ force: true }, function (err, data) {
                    if (data) {
                        for (i = 0; i < data.length; i++) {
                            if (data[i].Untagged) {
                                console.log(data[i].Untagged);
                            }
                            else if (data[i].Deleted) {
                                console.log(data[i].Deleted);
                            }
                        }
                        vscode.window.showInformationMessage(selectedItem.label + ' successfully removed');
                    }
                });
            }
        }
    });
}
exports.removeImage = removeImage;
//# sourceMappingURL=remove-image.js.map