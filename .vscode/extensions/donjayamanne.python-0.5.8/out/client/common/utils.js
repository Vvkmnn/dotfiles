/// <reference path="../../../node_modules/@types/node/index.d.ts" />
/// <reference path="../../../node_modules/vscode/vscode.d.ts" />
'use strict';
// TODO: Cleanup this place
// Add options for execPythonFile
const path = require('path');
const fs = require('fs');
const child_process = require('child_process');
const settings = require('./configSettings');
const helpers_1 = require('./helpers');
exports.IS_WINDOWS = /^win/.test(process.platform);
exports.PATH_VARIABLE_NAME = exports.IS_WINDOWS ? 'Path' : 'PATH';
const PathValidity = new Map();
function validatePath(filePath) {
    if (filePath.length === 0) {
        return Promise.resolve('');
    }
    if (PathValidity.has(filePath)) {
        return Promise.resolve(PathValidity.get(filePath) ? filePath : '');
    }
    return new Promise(resolve => {
        fs.exists(filePath, exists => {
            PathValidity.set(filePath, exists);
            return resolve(exists ? filePath : '');
        });
    });
}
exports.validatePath = validatePath;
function fsExistsAsync(filePath) {
    return new Promise(resolve => {
        fs.exists(filePath, exists => {
            PathValidity.set(filePath, exists);
            return resolve(exists);
        });
    });
}
exports.fsExistsAsync = fsExistsAsync;
let pythonInterpretterDirectory = null;
let previouslyIdentifiedPythonPath = null;
let customEnvVariables = null;
// If config settings change then clear env variables that we have cached
// Remember, the path to the python interpreter can change, hence we need to re-set the paths
settings.PythonSettings.getInstance().on('change', function () {
    customEnvVariables = null;
});
function getPythonInterpreterDirectory() {
    // If we already have it and the python path hasn't changed, yay
    if (pythonInterpretterDirectory && previouslyIdentifiedPythonPath === settings.PythonSettings.getInstance().pythonPath) {
        return Promise.resolve(pythonInterpretterDirectory);
    }
    return new Promise(resolve => {
        let pythonFileName = settings.PythonSettings.getInstance().pythonPath;
        // Check if we have the path
        if (path.basename(pythonFileName) === pythonFileName) {
            // No path provided
            return resolve('');
        }
        // If we can execute the python, then get the path from the fully qualified name
        child_process.execFile(pythonFileName, ['-c', 'print(1234)'], (error, stdout, stderr) => {
            // Yes this is a valid python path
            if (stdout.startsWith('1234')) {
                return resolve(path.dirname(pythonFileName));
            }
            // No idea, didn't work, hence don't reject, but return empty path
            resolve('');
        });
    }).then(value => {
        // Cache and return
        previouslyIdentifiedPythonPath = settings.PythonSettings.getInstance().pythonPath;
        return pythonInterpretterDirectory = value;
    }).catch(() => {
        // Don't care what the error is, all we know is that this doesn't work
        return pythonInterpretterDirectory = '';
    });
}
exports.getPythonInterpreterDirectory = getPythonInterpreterDirectory;
function getPathFromPythonCommand(args) {
    return execPythonFile(settings.PythonSettings.getInstance().pythonPath, args, __dirname).then(stdout => {
        if (stdout.length === 0) {
            return "";
        }
        let lines = stdout.split(/\r?\n/g).filter(line => line.length > 0);
        return validatePath(lines[0]);
    }).catch(() => {
        return "";
    });
}
exports.getPathFromPythonCommand = getPathFromPythonCommand;
function execPythonFile(file, args, cwd, includeErrorAsResponse = false, stdOut = null, token) {
    // If running the python file, then always revert to execFileInternal
    // Cuz python interpreter is always a file and we can and will always run it using child_process.execFile()
    if (file === settings.PythonSettings.getInstance().pythonPath) {
        if (stdOut) {
            return spawnFileInternal(file, args, { cwd }, includeErrorAsResponse, stdOut, token);
        }
        return execFileInternal(file, args, { cwd: cwd }, includeErrorAsResponse);
    }
    return getPythonInterpreterDirectory().then(pyPath => {
        // We don't have a path
        if (pyPath.length === 0) {
            if (stdOut) {
                return spawnFileInternal(file, args, { cwd }, includeErrorAsResponse, stdOut, token);
            }
            return execFileInternal(file, args, { cwd: cwd }, includeErrorAsResponse);
        }
        if (customEnvVariables === null) {
            // Ensure to include the path of the current python 
            let newPath = '';
            if (exports.IS_WINDOWS) {
                newPath = pyPath + '\\' + path.delimiter + path.join(pyPath, 'Scripts\\') + path.delimiter + process.env[exports.PATH_VARIABLE_NAME];
                // This needs to be done for windows
                process.env[exports.PATH_VARIABLE_NAME] = newPath;
            }
            else {
                newPath = pyPath + path.delimiter + process.env[exports.PATH_VARIABLE_NAME];
            }
            let customSettings = {};
            customSettings[exports.PATH_VARIABLE_NAME] = newPath;
            customEnvVariables = mergeEnvVariables(customSettings);
        }
        if (stdOut) {
            return spawnFileInternal(file, args, { cwd, env: customEnvVariables }, includeErrorAsResponse, stdOut, token);
        }
        return execFileInternal(file, args, { cwd, env: customEnvVariables }, includeErrorAsResponse);
    });
}
exports.execPythonFile = execPythonFile;
function handleResponse(file, includeErrorAsResponse, error, stdout, stderr) {
    return new Promise((resolve, reject) => {
        if (helpers_1.isNotInstalledError(error)) {
            return reject(error);
        }
        // pylint:
        //      In the case of pylint we have some messages (such as config file not found and using default etc...) being returned in stderr
        //      These error messages are useless when using pylint   
        if (includeErrorAsResponse && (stdout.length > 0 || stderr.length > 0)) {
            return resolve(stdout + '\n' + stderr);
        }
        let hasErrors = (error && error.message.length > 0) || (stderr && stderr.length > 0);
        if (hasErrors && (typeof stdout !== 'string' || stdout.length === 0)) {
            let errorMsg = (error && error.message) ? error.message : (stderr && stderr.length > 0 ? stderr + '' : '');
            return reject(errorMsg);
        }
        resolve(stdout + '');
    });
}
function execFileInternal(file, args, options, includeErrorAsResponse) {
    return new Promise((resolve, reject) => {
        child_process.execFile(file, args, options, (error, stdout, stderr) => {
            handleResponse(file, includeErrorAsResponse, error, stdout, stderr).then(resolve, reject);
        });
    });
}
function spawnFileInternal(file, args, options, includeErrorAsResponse, stdOut, token) {
    return new Promise((resolve, reject) => {
        let proc = child_process.spawn(file, args, options);
        let error = '';
        let exited = false;
        if (token && token.onCancellationRequested) {
            token.onCancellationRequested(() => {
                if (!exited && proc) {
                    proc.kill();
                    proc = null;
                }
            });
        }
        proc.on('error', error => {
            return reject(error);
        });
        proc.stdout.setEncoding('utf8');
        proc.stderr.setEncoding('utf8');
        proc.stdout.on('data', function (data) {
            if (token && token.isCancellationRequested) {
                return;
            }
            stdOut(data);
        });
        proc.stderr.on('data', function (data) {
            if (token && token.isCancellationRequested) {
                return;
            }
            if (includeErrorAsResponse) {
                stdOut(data);
            }
            else {
                error += data;
            }
        });
        proc.on('exit', function (code) {
            exited = true;
            if (token && token.isCancellationRequested) {
                return reject();
            }
            if (error.length > 0) {
                return reject(error);
            }
            resolve();
        });
    });
}
function execInternal(command, args, options, includeErrorAsResponse) {
    return new Promise((resolve, reject) => {
        child_process.exec([command].concat(args).join(' '), options, (error, stdout, stderr) => {
            handleResponse(command, includeErrorAsResponse, error, stdout, stderr).then(resolve, reject);
        });
    });
}
function mergeEnvVariables(newVariables) {
    for (let setting in process.env) {
        if (!newVariables[setting]) {
            newVariables[setting] = process.env[setting];
        }
    }
    return newVariables;
}
exports.mergeEnvVariables = mergeEnvVariables;
function formatErrorForLogging(error) {
    let message = '';
    if (typeof error === 'string') {
        message = error;
    }
    else {
        if (error.message) {
            message = `Error Message: ${error.message}`;
        }
        if (error.name && error.message.indexOf(error.name) === -1) {
            message += `, (${error.name})`;
        }
        const innerException = error.innerException;
        if (innerException && (innerException.message || innerException.name)) {
            if (innerException.message) {
                message += `, Inner Error Message: ${innerException.message}`;
            }
            if (innerException.name && innerException.message.indexOf(innerException.name) === -1) {
                message += `, (${innerException.name})`;
            }
        }
    }
    return message;
}
exports.formatErrorForLogging = formatErrorForLogging;
function getSubDirectories(rootDir) {
    return new Promise(resolve => {
        fs.readdir(rootDir, (error, files) => {
            if (error) {
                return resolve([]);
            }
            const subDirs = [];
            files.forEach(name => {
                const fullPath = path.join(rootDir, name);
                try {
                    if (fs.statSync(fullPath).isDirectory()) {
                        subDirs.push(fullPath);
                    }
                }
                catch (ex) {
                }
            });
            resolve(subDirs);
        });
    });
}
exports.getSubDirectories = getSubDirectories;
//# sourceMappingURL=utils.js.map