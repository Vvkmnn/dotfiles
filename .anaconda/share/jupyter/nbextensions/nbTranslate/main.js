// Copyright (c) Jupyter-Contrib Team.
// Distributed under the terms of the Modified BSD License.
// Author: Jean-François Bercher 

define(function(require, exports, module) {
    'use strict';

    var $ = require('jquery');
    var Jupyter = require('base/js/namespace');
    var keyboard = require('base/js/keyboard');
    var Cell = require('notebook/js/cell').Cell;
    var CodeCell = require('notebook/js/codecell').CodeCell;

    var nbt = require('nbextensions/nbTranslate/nbTranslate');
    var mutils = require('nbextensions/nbTranslate/mutils');
    var sourceLang;
    var targetLang;
    var displayLangs;
    var useGoogleTranslate;

    var add_edit_shortcuts = {};
    var log_prefix = '[' + module.id + '] ';

    // default config (updated on nbextension load)
    var conf = {
        hotkey: 'alt-t',
        sourceLang: 'en',
        targetLang: 'fr',
        displayLangs: ['*'],
        langInMainMenu: true,
        useGoogleTranslate: true
    }


    function initialize(conf) {
        Jupyter.notebook.config.loaded.then(function config_loaded_callback() {            
            // config may be specified at system level or at document level.
      // first, update defaults with config loaded from server
      conf =  $.extend(false, {}, conf, Jupyter.notebook.config.data.nbTranslate);
      // then update cfg with any found in current notebook metadata
      // and save in nb metadata (then can be modified per document)
      conf = Jupyter.notebook.metadata.nbTranslate = $.extend(false, {}, conf,
          Jupyter.notebook.metadata.nbTranslate);
      //conf.displayLangs = Jupyter.notebook.metadata.nbTranslate.displayLangs = $.makeArray($.extend(true, {}, conf.displayLangs, Jupyter.notebook.metadata.nbTranslate.displayLangs));
            // other initializations
            sourceLang = conf.sourceLang;
            targetLang = conf.targetLang;
            displayLangs = conf.displayLangs;
            useGoogleTranslate = conf.useGoogleTranslate;
            // then
            translateHotkey(conf);
            showToolbar();
            main_function(conf);
            buildTranslateToolbar();
        })
        return conf
    }


    function showToolbar() {
        if ($('#showToolbar').length == 0) {
            Jupyter.toolbar.add_buttons_group([{
                'label': 'Translate current cell',
                'icon': 'fa-language',
                'callback': translateCurrentCell,
                'id': 'showToolbar'
            },
            {
            'label': 'nbTranslate: Configuration (toggle toolbar)',
            'icon': 'fa-wrench',
            'callback': translateToolbarToggle //translateToolbar
        }]);
        }
    }

    function translateHotkey(conf) {
        add_edit_shortcuts[conf['hotkey']] = {
            help: "Translate current cell",
            help_index: 'yf',
            handler: translateCurrentCell
        };
        Jupyter.keyboard_manager.edit_shortcuts.add_shortcuts(add_edit_shortcuts);
        Jupyter.keyboard_manager.command_shortcuts.add_shortcuts(add_edit_shortcuts);
    }

    function main_function(conf) {
        //alert(log_prefix+" main_function output")
        show_mdcells(conf.displayLangs);
        // add the targetLang to the list of langs, if not already present
        if (listOfLangsInNotebook.indexOf(conf.targetLang) == -1) {
                listOfLangsInNotebook.push(targetLang);
            }
        // add the sourceLang to the list of langs, if not already present
        if (listOfLangsInNotebook.indexOf(conf.sourceLang) == -1) {
                listOfLangsInNotebook.push(sourceLang);
            }
        // Display only the langs present in notebook 
        if (conf.displayLangs.indexOf('*') == -1) {
            conf.displayLangs = $.makeArray($(listOfLangsInNotebook).filter(conf.displayLangs));
        }
        else {
            conf.displayLangs = ['*'];
        }
        // console.log(log_prefix, "Displaying langs ", conf.displayLangs);

    }

    function load_notebook_extension() {

        // Wait for the notebook to be fully loaded
        if (Jupyter.notebook._fully_loaded) {
            // this tests if the notebook is fully loaded 
            console.log(log_prefix + "Notebook fully loaded -- nbTranslate initialized ")
            conf = initialize(conf);
        } else {
            console.log(log_prefix + "Waiting for notebook availability")
            $([Jupyter.events]).on("notebook_loaded.Notebook", function() {
                console.log(log_prefix + "nbTranslate initialized (via notebook_loaded)")
                conf = initialize(conf);                
            })
        }

    }


    return {
        load_ipython_extension: load_notebook_extension
    };
});
