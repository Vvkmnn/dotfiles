var helper = {};

var vscode = require('vscode');
var Window = vscode.window;
var Workspace = vscode.workspace;

var language = require('./language');
var Todo = require('./models').Todo;

helper.getUsersWorkspaceConfigurations = function() {
  return Workspace.getConfiguration();  
};

helper.getFileExtensionForLanguage = function(choosenLanguage) {
    return language[choosenLanguage].extension;
};

helper.getFileExludeForLanguage = function(choosenLanguage, workspaceConfig) {
    var exclude = '{' + '.vscode' + language[choosenLanguage].exclude;
    if (workspaceConfig.todoIgnore) {
        var usersExclude = '';
        for (var i = 0; i < workspaceConfig.todoIgnore.length; i++) {
            var conf = workspaceConfig.todoIgnore[i].trim();
            if (conf !== '') {
                usersExclude += ',' + conf;
            }
        }
        exclude += usersExclude + '}';
    }
    return exclude;
};

helper.getScanRegexForLanguage = function(choosenLanguage, workspaceConfig) {
    //TODO: Add per-language specific scan expressions
    var regex = "(?:TODO|FIXME)\\s*\\W{0,1}(\\s+.*|(?:\\w|\\d).*)$";
    if(workspaceConfig.todoScanRegex){
        regex = workspaceConfig.todoScanRegex;
    }
    return regex;
};

var getTodoMessage = function(lineText, match) {
    var todoMessage = lineText.substring(lineText.indexOf(match[1]), lineText.length);
    if (todoMessage.length > 60) {
        todoMessage = todoMessage.substring(0, 57).trim();
        todoMessage += '...';
    }
    return todoMessage;
};

var getTodoLocation = function(pathWithoutFile, todoMessage, line, match) {
    var rootPath = Workspace.rootPath + '/';
    var outputFile = pathWithoutFile.replace(rootPath, '');
    var todoLocation = outputFile + ' ' + (line + 1) + ':' + (todoMessage.indexOf(match[1]) + 1);
    if (todoLocation.length > 50) {
        todoLocation = '...' + todoLocation.substring(todoLocation.length - 47, todoLocation.length);
    }
    return todoLocation;
};

var findTodosinSpecifiedFile = function(file, todos, todosList, scanRegex) {
    var fileInUri = file.uri.toString();
    var pathWithoutFile = fileInUri.substring(7, fileInUri.length);
    
    var regex = new RegExp(scanRegex, "i");
    
    for (var line = 0; line < file.lineCount; line++) {
        var lineText = file.lineAt(line).text;
        var match = lineText.match(regex);
        if (match !== null) {
            if (!todos.hasOwnProperty(pathWithoutFile)) {
                todos[pathWithoutFile] = [];
            }
            var todoMessage = getTodoMessage(lineText, match);
            var todoLocation = getTodoLocation(pathWithoutFile, todoMessage, line, match);
            var todo = new Todo(todoLocation, pathWithoutFile, line, todoMessage, 10);
            todosList.push(todo);
            todos[pathWithoutFile].push(todo);
        }
    }
};

var findTodosinFiles = function(files, choosenLanguage, scanRegex, done) {
    var todos = {};
    todosList = [];
    var times = 0;
    if (files.length === 0) {
        Window.showInformationMessage('There is no **' + choosenLanguage + '** files in the open project.');
        // errors
        done({ message: 'no files' }, null, null);
    } else {
        for (var i = 0; i < files.length; i++) {
            Workspace.openTextDocument(files[i]).then(function(file) {
                findTodosinSpecifiedFile(file, todos, todosList, scanRegex);
            }).then(function() {
                times++;
                if (times === files.length) {
                    return done(null, todos, todosList);
                }
            });
        }
    }
};

helper.findFiles = function(extension, exclude, choosenLanguage, scanRegex, done) {
    Workspace.findFiles(extension, exclude, 1000).then(function(files) {
        findTodosinFiles(files, choosenLanguage, scanRegex, function(err, todos, todosList) {
            done(err, todos, todosList);
        });
    });
};

helper.createStatusBarItem = function() {
    var statusBarItem = Window.createStatusBarItem(vscode.StatusBarAlignment.Left);
    statusBarItem.text = 'TODO:s';
    statusBarItem.tooltip = 'Show TODO:s';
    statusBarItem.command = 'extension.showTodos';
    statusBarItem.color = '#FFFFFF';
    statusBarItem.show();
    return statusBarItem;
};

module.exports = helper;