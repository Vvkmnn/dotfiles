'use strict';
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_1 = require("vscode");
const common_1 = require("./common");
const logger_1 = require("../logger");
class ClearFileAnnotationsCommand extends common_1.EditorCommand {
    constructor(annotationController) {
        super(common_1.Commands.ClearFileAnnotations);
        this.annotationController = annotationController;
    }
    execute(editor, edit, uri) {
        return __awaiter(this, void 0, void 0, function* () {
            if (editor === undefined || editor.document === undefined || editor.document.isDirty)
                return undefined;
            try {
                return this.annotationController.clear(editor.viewColumn || -1);
            }
            catch (ex) {
                logger_1.Logger.error(ex, 'ClearFileAnnotationsCommand');
                return vscode_1.window.showErrorMessage(`Unable to clear file annotations. See output channel for more details`);
            }
        });
    }
}
exports.ClearFileAnnotationsCommand = ClearFileAnnotationsCommand;
//# sourceMappingURL=clearFileAnnotations.js.map