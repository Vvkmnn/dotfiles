"use strict";
const vscode = require("vscode");
const vscode_extensions_1 = require("../utils/vscode-extensions");
const messages_1 = require("../messages");
const icon_manifest_1 = require("../icon-manifest");
const supportedExtensions_1 = require("../icon-manifest/supportedExtensions");
const supportedFolders_1 = require("../icon-manifest/supportedFolders");
const settings_1 = require("../settings");
function registerCommands(context) {
    registerCommand(context, 'regenerateIcons', applyCustomizationCommand);
    registerCommand(context, 'restoreIcons', restoreDefaultManifestCommand);
    registerCommand(context, 'resetProjectDetectionDefaults', resetProjectDetectionDefaultsCommand);
    registerCommand(context, 'ngPreset', toggleAngularPresetCommand);
    registerCommand(context, 'jsPreset', toggleJsPresetCommand);
    registerCommand(context, 'tsPreset', toggleTsPresetCommand);
    registerCommand(context, 'jsonPreset', toggleJsonPresetCommand);
    registerCommand(context, 'hideFoldersPreset', toggleHideFoldersCommand);
}
exports.registerCommands = registerCommands;
function registerCommand(context, name, callback, thisArg) {
    const command = vscode.commands.registerCommand(`extension.${name}`, callback);
    context.subscriptions.push(command);
    return command;
}
function applyCustomizationCommand() {
    const message = `${messages_1.messages.iconCustomizationMessage} ${messages_1.messages.restart}`;
    showCustomizationMessage(message, [{ title: messages_1.messages.reload }], applyCustomization);
}
exports.applyCustomizationCommand = applyCustomizationCommand;
function restoreDefaultManifestCommand() {
    const message = `${messages_1.messages.iconRestoreMessage} ${messages_1.messages.restart}`;
    showCustomizationMessage(message, [{ title: messages_1.messages.reload }], restoreManifest);
}
function resetProjectDetectionDefaultsCommand() {
    const message = `${messages_1.messages.projectDetecticonResetMessage}`;
    showCustomizationMessage(message, [{ title: messages_1.messages.reload }], resetProjectDetectionDefaults);
}
function toggleAngularPresetCommand() {
    const preset = 'angular';
    const value = getToggleValue(preset);
    const message = `${messages_1.messages.ngPresetMessage} ${value ? messages_1.messages.enabled : messages_1.messages.disabled}. ${messages_1.messages.restart}`;
    togglePreset(preset, value, false);
    showCustomizationMessage(message, [{ title: messages_1.messages.reload }], applyCustomization, cancel, preset, !value, false);
}
function toggleJsPresetCommand() {
    const preset = 'jsOfficial';
    const value = getToggleValue(preset);
    const message = `${messages_1.messages.jsOfficialPresetMessage} ${value ? messages_1.messages.enabled : messages_1.messages.disabled}. ${messages_1.messages.restart}`;
    togglePreset(preset, value);
    showCustomizationMessage(message, [{ title: messages_1.messages.reload }], applyCustomization, cancel, preset, !value);
}
function toggleTsPresetCommand() {
    const preset = 'tsOfficial';
    const value = getToggleValue(preset);
    const message = `${messages_1.messages.tsOfficialPresetMessage} ${value ? messages_1.messages.enabled : messages_1.messages.disabled}. ${messages_1.messages.restart}`;
    togglePreset(preset, value);
    showCustomizationMessage(message, [{ title: messages_1.messages.reload }], applyCustomization, cancel, preset, !value);
}
function toggleJsonPresetCommand() {
    const preset = 'jsonOfficial';
    const value = getToggleValue(preset);
    const message = `${messages_1.messages.jsonOfficialPresetMessage} ${value ? messages_1.messages.enabled : messages_1.messages.disabled}. ${messages_1.messages.restart}`;
    togglePreset(preset, value);
    showCustomizationMessage(message, [{ title: messages_1.messages.reload }], applyCustomization, cancel, preset, !value);
}
function toggleHideFoldersCommand() {
    const preset = 'hideFolders';
    const value = getToggleValue(preset);
    const message = `${messages_1.messages.hideFoldersPresetMessage} ${value ? messages_1.messages.disabled : messages_1.messages.enabled}. ${messages_1.messages.restart}`;
    togglePreset(preset, value);
    showCustomizationMessage(message, [{ title: messages_1.messages.reload }], applyCustomization, cancel, preset, !value);
}
function getToggleValue(preset) {
    return !vscode_extensions_1.getConfig().vsicons.presets[preset];
}
function togglePreset(preset, newvalue, global = true) {
    return vscode_extensions_1.getConfig().update(`vsicons.presets.${preset}`, newvalue, global);
}
exports.togglePreset = togglePreset;
function showCustomizationMessage(message, items, callback, cancel, ...args) {
    vscode.window.showInformationMessage(message, ...items)
        .then(btn => {
        if (!btn) {
            if (cancel) {
                cancel(...args);
            }
            return;
        }
        if (btn.title === messages_1.messages.disableDetect) {
            vscode_extensions_1.getConfig().update('vsicons.projectDetection.disableDetect', true, true);
            return;
        }
        if (btn.title === messages_1.messages.autoReload) {
            vscode_extensions_1.getConfig().update('vsicons.projectDetection.autoReload', true, true);
        }
        if (callback) {
            callback(...args);
        }
        reload();
    }, (reason) => {
        // tslint:disable-next-line:no-console
        console.log('Rejected because: ', reason);
        return;
    });
}
exports.showCustomizationMessage = showCustomizationMessage;
function reload() {
    vscode.commands.executeCommand('workbench.action.reloadWindow');
}
exports.reload = reload;
function cancel(preset, value, global = true) {
    togglePreset(preset, value, global);
}
exports.cancel = cancel;
function applyCustomization() {
    const associations = vscode_extensions_1.getConfig().vsicons.associations;
    const customFiles = {
        default: associations.fileDefault,
        supported: associations.files,
    };
    const customFolders = {
        default: associations.folderDefault,
        supported: associations.folders,
    };
    generateManifest(customFiles, customFolders);
}
exports.applyCustomization = applyCustomization;
function generateManifest(customFiles, customFolders) {
    const iconGenerator = new icon_manifest_1.IconGenerator(vscode, icon_manifest_1.schema);
    const presets = vscode_extensions_1.getConfig().vsicons.presets;
    let workingCustomFiles = customFiles;
    let workingCustomFolders = customFolders;
    if (customFiles) {
        // check presets...
        workingCustomFiles = icon_manifest_1.toggleAngularPreset(!presets.angular, customFiles);
        workingCustomFiles = icon_manifest_1.toggleOfficialIconsPreset(!presets.jsOfficial, workingCustomFiles, ['js_official'], ['js']);
        workingCustomFiles = icon_manifest_1.toggleOfficialIconsPreset(!presets.tsOfficial, workingCustomFiles, ['typescript_official', 'typescriptdef_official'], ['typescript', 'typescriptdef']);
        workingCustomFiles = icon_manifest_1.toggleOfficialIconsPreset(!presets.jsonOfficial, workingCustomFiles, ['json_official'], ['json']);
    }
    if (customFolders) {
        workingCustomFolders = icon_manifest_1.toggleHideFoldersPreset(presets.hideFolders, workingCustomFolders);
    }
    // presets affecting default icons
    const workingFiles = icon_manifest_1.toggleAngularPreset(!presets.angular, supportedExtensions_1.extensions);
    const workingFolders = icon_manifest_1.toggleHideFoldersPreset(presets.hideFolders, supportedFolders_1.extensions);
    const json = icon_manifest_1.mergeConfig(workingCustomFiles, workingFiles, workingCustomFolders, workingFolders, iconGenerator);
    iconGenerator.persist(settings_1.extensionSettings.iconJsonFileName, json);
}
function restoreManifest() {
    const iconGenerator = new icon_manifest_1.IconGenerator(vscode, icon_manifest_1.schema, true);
    const json = icon_manifest_1.mergeConfig(null, supportedExtensions_1.extensions, null, supportedFolders_1.extensions, iconGenerator);
    iconGenerator.persist(settings_1.extensionSettings.iconJsonFileName, json);
}
function resetProjectDetectionDefaults() {
    const conf = vscode_extensions_1.getConfig();
    if (conf.vsicons.projectDetection.autoReload) {
        conf.update('vsicons.projectDetection.autoReload', false, true);
    }
    if (conf.vsicons.projectDetection.disableDetect) {
        conf.update('vsicons.projectDetection.disableDetect', false, true);
    }
}
//# sourceMappingURL=index.js.map