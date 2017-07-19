"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const vscode_extensions_1 = require("../utils/vscode-extensions");
const i18n_1 = require("../i18n");
const iconManifest = require("../icon-manifest");
const supportedExtensions_1 = require("../icon-manifest/supportedExtensions");
const supportedFolders_1 = require("../icon-manifest/supportedFolders");
const models = require("../models");
const settings_1 = require("../settings");
const init_1 = require("../init");
const helper = require("./helper");
const i18nManager = new i18n_1.LanguageResourceManager(vscode.env.language);
const initVSIconsConfig = vscode_extensions_1.getVsiconsConfig();
let doReload;
let customMsgShown;
let cb;
let argms;
vscode.workspace.onDidChangeConfiguration(didChangeConfigurationListener);
function didChangeConfigurationListener() {
    if (doReload) {
        doReload = false;
        // 'vscode' team still hasn't fixed this: In case the 'user settings' file has just been created
        // a delay needs to be introduced in order for the preset change to get persisted on disk.
        setTimeout(() => {
            executeAndReload(cb, ...argms);
        }, 500);
    }
    else if (!customMsgShown) {
        init_1.manageApplyCustomizations(initVSIconsConfig, vscode_extensions_1.getVsiconsConfig(), applyCustomizationCommand, [{ title: i18nManager.getMessage(models.LangResourceKeys.dontShowThis) }]);
    }
}
function registerCommands(context) {
    registerCommand(context, 'regenerateIcons', applyCustomizationCommand);
    registerCommand(context, 'restoreIcons', restoreDefaultManifestCommand);
    registerCommand(context, 'resetProjectDetectionDefaults', resetProjectDetectionDefaultsCommand);
    registerCommand(context, 'ngPreset', toggleAngularPresetCommand);
    registerCommand(context, 'jsPreset', toggleJsPresetCommand);
    registerCommand(context, 'tsPreset', toggleTsPresetCommand);
    registerCommand(context, 'jsonPreset', toggleJsonPresetCommand);
    registerCommand(context, 'hideFoldersPreset', toggleHideFoldersPresetCommand);
    registerCommand(context, 'foldersAllDefaultIconPreset', toggleFoldersAllDefaultIconPresetCommand);
}
exports.registerCommands = registerCommands;
function registerCommand(context, name, callback) {
    const command = vscode.commands.registerCommand(`vscode-icons.${name}`, callback);
    context.subscriptions.push(command);
    return command;
}
function applyCustomizationCommand(additionalTitles = []) {
    const message = i18nManager.getMessage(models.LangResourceKeys.iconCustomization, ' ', models.LangResourceKeys.restart);
    showCustomizationMessage(message, [{ title: i18nManager.getMessage(models.LangResourceKeys.reload) }, ...additionalTitles], applyCustomization);
}
exports.applyCustomizationCommand = applyCustomizationCommand;
function restoreDefaultManifestCommand() {
    const message = i18nManager.getMessage(models.LangResourceKeys.iconRestore, ' ', models.LangResourceKeys.restart);
    showCustomizationMessage(message, [{ title: i18nManager.getMessage(models.LangResourceKeys.reload) }], restoreManifest);
}
function resetProjectDetectionDefaultsCommand() {
    const message = i18nManager.getMessage(models.LangResourceKeys.projectDetectionReset, ' ', models.LangResourceKeys.restart);
    showCustomizationMessage(message, [{ title: i18nManager.getMessage(models.LangResourceKeys.reload) }], resetProjectDetectionDefaults);
}
function toggleAngularPresetCommand() {
    togglePreset('angular', 'ngPreset', false, false);
}
function toggleJsPresetCommand() {
    togglePreset('jsOfficial', 'jsOfficialPreset');
}
function toggleTsPresetCommand() {
    togglePreset('tsOfficial', 'tsOfficialPreset');
}
function toggleJsonPresetCommand() {
    togglePreset('jsonOfficial', 'jsonOfficialPreset');
}
function toggleHideFoldersPresetCommand() {
    togglePreset('hideFolders', 'hideFoldersPreset', true);
}
function toggleFoldersAllDefaultIconPresetCommand() {
    togglePreset('foldersAllDefaultIcon', 'foldersAllDefaultIconPreset', true);
}
function togglePreset(preset, presetKey, reverseAction = false, global = true) {
    const toggledValue = helper.isFolders(preset)
        ? init_1.folderIconsDisabled(helper.getFunc(preset))
        : init_1.iconsDisabled(helper.getIconName(preset));
    const action = reverseAction
        ? toggledValue
            ? 'Disabled'
            : 'Enabled'
        : toggledValue
            ? 'Enabled'
            : 'Disabled';
    if (!Reflect.has(models.LangResourceKeys, `${presetKey}${action}`)) {
        throw Error(`${presetKey}${action} is not valid`);
    }
    const message = `${i18nManager.getMessage(models.LangResourceKeys[`${presetKey}${action}`], ' ', models.LangResourceKeys.restart)}`;
    showCustomizationMessage(message, [{ title: i18nManager.getMessage(models.LangResourceKeys.reload) }], applyCustomization, preset, toggledValue, global);
}
function updatePreset(preset, toggledValue, global = true) {
    const removePreset = vscode_extensions_1.getConfig().inspect(`vsicons.presets.${preset}`).defaultValue === toggledValue;
    return vscode_extensions_1.getConfig().update(`vsicons.presets.${preset}`, removePreset ? undefined : toggledValue, global);
}
exports.updatePreset = updatePreset;
function showCustomizationMessage(message, items, callback, ...args) {
    customMsgShown = true;
    return vscode.window.showInformationMessage(message, ...items)
        .then(btn => handleAction(btn, callback, ...args), 
    // tslint:disable-next-line:no-console
    reason => console.info('Rejected because: ', reason));
}
exports.showCustomizationMessage = showCustomizationMessage;
function executeAndReload(callback, ...args) {
    if (callback) {
        callback(...args);
    }
    reload();
}
function handleAction(btn, callback, ...args) {
    if (!btn) {
        customMsgShown = false;
        return;
    }
    cb = callback;
    argms = args;
    const handlePreset = () => {
        // If the preset is the same as the toggle value then trigger an explicit reload
        // Note: This condition works also for auto-reload handling
        if (vscode_extensions_1.getConfig().vsicons.presets[args[0]] === args[1]) {
            executeAndReload(callback, ...args);
        }
        else {
            if (args.length !== 3) {
                throw new Error('Arguments mismatch');
            }
            doReload = true;
            updatePreset(args[0], args[1], args[2]);
        }
    };
    switch (btn.title) {
        case i18nManager.getMessage(models.LangResourceKeys.dontShowThis):
            {
                doReload = false;
                if (!callback) {
                    break;
                }
                switch (callback.name) {
                    case 'applyCustomization':
                        {
                            customMsgShown = false;
                            vscode_extensions_1.getConfig().update('vsicons.dontShowConfigManuallyChangedMessage', true, true);
                        }
                        break;
                    default:
                        break;
                }
            }
            break;
        case i18nManager.getMessage(models.LangResourceKeys.disableDetect):
            {
                doReload = false;
                vscode_extensions_1.getConfig().update('vsicons.projectDetection.disableDetect', true, true);
            }
            break;
        case i18nManager.getMessage(models.LangResourceKeys.autoReload):
            {
                vscode_extensions_1.getConfig().update('vsicons.projectDetection.autoReload', true, true)
                    .then(() => handlePreset());
            }
            break;
        case i18nManager.getMessage(models.LangResourceKeys.reload):
            {
                if (!args || args.length !== 3) {
                    executeAndReload(callback, ...args);
                    break;
                }
                handlePreset();
            }
            break;
        default:
            break;
    }
}
function reload() {
    vscode.commands.executeCommand('workbench.action.reloadWindow');
}
exports.reload = reload;
function applyCustomization(projectDetectionResult = null) {
    const associations = vscode_extensions_1.getVsiconsConfig().associations;
    const customFiles = {
        default: associations.fileDefault,
        supported: associations.files,
    };
    const customFolders = {
        default: associations.folderDefault,
        supported: associations.folders,
    };
    generateManifest(customFiles, customFolders, projectDetectionResult);
}
exports.applyCustomization = applyCustomization;
function generateManifest(customFiles, customFolders, projectDetectionResult = null) {
    const iconGenerator = new iconManifest.IconGenerator(vscode, iconManifest.schema);
    const vsicons = vscode_extensions_1.getVsiconsConfig();
    const hasProjectDetectionResult = projectDetectionResult &&
        typeof projectDetectionResult === 'object' &&
        'value' in projectDetectionResult;
    const angularPreset = hasProjectDetectionResult
        ? projectDetectionResult.value
        : vsicons.presets.angular;
    let workingCustomFiles = customFiles;
    let workingCustomFolders = customFolders;
    if (customFiles) {
        // check presets...
        workingCustomFiles = iconManifest.toggleAngularPreset(!angularPreset, customFiles);
        workingCustomFiles = iconManifest.toggleOfficialIconsPreset(!vsicons.presets.jsOfficial, workingCustomFiles, ['js_official'], ['js']);
        workingCustomFiles = iconManifest.toggleOfficialIconsPreset(!vsicons.presets.tsOfficial, workingCustomFiles, ['typescript_official', 'typescriptdef_official'], ['typescript', 'typescriptdef']);
        workingCustomFiles = iconManifest.toggleOfficialIconsPreset(!vsicons.presets.jsonOfficial, workingCustomFiles, ['json_official'], ['json']);
    }
    if (customFolders) {
        workingCustomFolders = iconManifest.toggleFoldersAllDefaultIconPreset(vsicons.presets.foldersAllDefaultIcon, customFolders);
        workingCustomFolders = iconManifest.toggleHideFoldersPreset(vsicons.presets.hideFolders, workingCustomFolders);
    }
    // presets affecting default icons
    const workingFiles = iconManifest.toggleAngularPreset(!angularPreset, supportedExtensions_1.extensions);
    let workingFolders = iconManifest.toggleFoldersAllDefaultIconPreset(vsicons.presets.foldersAllDefaultIcon, supportedFolders_1.extensions);
    workingFolders = iconManifest.toggleHideFoldersPreset(vsicons.presets.hideFolders, workingFolders);
    const json = iconManifest.mergeConfig(workingCustomFiles, workingFiles, workingCustomFolders, workingFolders, iconGenerator);
    iconGenerator.persist(settings_1.extensionSettings.iconJsonFileName, json);
}
function restoreManifest() {
    const iconGenerator = new iconManifest.IconGenerator(vscode, iconManifest.schema, true);
    const json = iconManifest.mergeConfig(null, supportedExtensions_1.extensions, null, supportedFolders_1.extensions, iconGenerator);
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