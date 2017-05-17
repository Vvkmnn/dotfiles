var language = {};

var all = 'All';
var go = 'Go';
var javascript = 'Javascript';
var php = 'PHP';
var coffeescript = 'CoffeeScript';
var c = 'C';
var cpp = 'C++';
var csharp = 'C#';
var objectivec = 'Objective-C';
var python = 'Python';
var ruby = 'Ruby';
var swift = 'Swift';
var typescript = 'TypeScript';
var visualbasic = 'VisualBasic';
var rust = 'Rust';
var elm = "Elm"
var typescriptReact = 'TypeScript-React'

language[all] = {
    name: all,
    extension: '**/*',
    exclude: '',
};

language[go] = {
    name: go,
    alias: 'go',
    extension: '**/*.go',
    exclude: '',
};

language[javascript] = {
    name: javascript,
    alias: 'javascript',
    extension: '**/*.js',
    exclude: '**/node_modules/**',
};

language[php] = {
    name: php,
    alias: 'php',
    extension: '**/*.php',
    exclude: '',
};

language[coffeescript] = {
    name: coffeescript,
    alias: 'coffeescript',
    extension: '**/*[.js].coffee',
    exclude: '**/node_modules/**',
};

language[c] = {
    name: c,
    alias: 'c',
    extension: '**/*.c',
    exclude: '',
};

language[cpp] = {
    name: cpp,
    alias: 'cpp',
    extension: '**/*.cpp',
    exclude: '',
};

language[csharp] = {
    name: csharp,
    alias: 'csharp',
    extension: '**/*.cs',
    exclude: '',
};

language[objectivec] = {
    name: objectivec,
    alias: 'objectivec',
    extension: '**/*.m',
    exclude: '',
};

language[python] = {
    name: python,
    alias: 'python',
    extension: '**/*.py',
    exclude: '',
};

language[ruby] = {
    name: ruby,
    alias: 'ruby',
    extension: '**/*.rb',
    exclude: '',
};

language[swift] = {
    name: swift,
    alias: 'swift',
    extension: '**/*.swift',
    exclude: '',
};

language[typescript] = {
    name: typescript,
    alias: 'typescript',
    extension: '**/*.ts',
    exclude: '**/node_modules/**',
};

language[visualbasic] = {
    name: visualbasic,
    alias: 'visualbasic',
    extension: '**/*.vb',
    exclude: '',
};

language[rust] = {
    name: rust,
    alias: 'rust',
    extension: '**/*.rs',
    exclude: '',
};

language[elm] = { 
    name: elm,
    alias: 'elm',
    extension: '**/*.elm',
    exclude: '',
}

language[typescriptReact] = {
    name: typescriptReact,
    alias: 'typescriptreact',
    extension: '**/*.tsx',
    exclude: '',
}

language.all = [language[all], language[go], language[javascript],
    language[php], language[coffeescript], language[c], language[cpp],
    language[csharp], language[objectivec], language[python], language[ruby],
    language[swift], language[typescript], language[visualbasic], language[rust],
    language[elm], language[typescriptReact]
];

language.allName = [all, go, javascript, php, coffeescript, c, cpp, csharp,
    objectivec, python, ruby, swift, typescript, visualbasic, rust, elm,
    typescriptReact
];

module.exports = language;
