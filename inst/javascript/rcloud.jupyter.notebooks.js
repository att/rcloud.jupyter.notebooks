
((function() {

    function download_as_file(filename, content, mimetype) {
        var file = new Blob([content], {type: mimetype});
        saveAs(file, filename); // FileSaver.js
    }

    return {
        init: function(ocaps, k) {

            // Are we in a notebook?
            if (RCloud.UI.advanced_menu.add) {

                var oc = RCloud.promisify_paths(ocaps, [
                    [ 'importIpynb' ],
                    [ 'exportIpynb' ]
                ], true);

                RCloud.UI.advanced_menu.add({

                    jupImport: {
                        sort: 11001,
                        text: 'Import Jupyter Notebook',
                        modes: ['edit'],
                        action: function() {
                            var that = this;

                            function create_import_file_dialog() {
                                var rmd_raw = null;
                                var notebook = null;
                                var rmd_status = null;
                                var rmd_filename = null;
                                var import_button = null;

                                function do_upload(file) {

                                    rmd_status.hide();
                                    var fr = new FileReader();
                                    fr.onloadend = function(e) {

                                        rmd_status.show();
                                        rmd_status.html(
                                            '<pre>' + fr.result.split("\n")
                                                .slice(0,15)
                                                .join("\n") + '\n...\n</pre>'
                                        );
                                        ui_utils.enable_bs_button(import_button);
                                        rmd_raw = fr.result;
                                        rmd_filename = file.name;
                                    };
                                    fr.readAsText(file);
                                }

                                function do_import() {

                                    // Need to call back to R to import the notebook
                                    var jsonData = JSON.parse(rmd_raw);
                                    oc.importIpynb(jsonData, rmd_filename).then(
                                        function(notebook) {
                                            console.log(notebook);
                                            if (notebook) {
                                                editor.star_notebook(true, {notebook: notebook}).then(function() {
                                                    editor.set_notebook_visibility(notebook.id, true);

                                                    // highlight the node:
                                                    editor.highlight_imported_notebooks(notebook);
                                                });
                                            }

                                            dialog.modal('hide');
                                        }
                                    );
                                }

                                var body = $('<div class="container"/>');
                                var file_select = $('<input type="file" id="jupyter-file-upload" size="50"></input>');

                                file_select
                                    .click(function() {
                                        ui_utils.disable_bs_button(import_button);
                                        rmd_status.hide();
                                        file_select.val(null);
                                    })
                                    .change(function() {
                                        do_upload(file_select[0].files[0]);
                                    });

                                rmd_status = $('<div />');
                                rmd_status.append(rmd_status);

                                body.append($('<p/>').append(file_select))
                                    .append($('<p/>').append(rmd_status.hide()));
                                var cancel = $('<span class="btn btn-cancel">Cancel</span>')
                                    .on('click', function() { $(dialog).modal('hide'); });
                                import_button = $('<span class="btn btn-primary">Import</span>')
                                    .on('click', do_import);

                                ui_utils.disable_bs_button(import_button);

                                var footer = $('<div class="modal-footer"></div>')
                                    .append(cancel).append(import_button);
                                var header = $(['<div class="modal-header">',
                                                '<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>',
                                                '<h3>Import Jupyter Notebook</h3>',
                                                '</div>'].join(''));
                                var dialog = $('<div id="import-jupyter-file-dialog" class="modal fade"></div>')
                                    .append($('<div class="modal-dialog"></div>')
                                            .append($('<div class="modal-content"></div>')
                                                    .append(header).append(body).append(footer)));
                                $("body").append(dialog);
                                dialog
                                    .on('show.bs.modal', function() {
                                        $("#jupyter-file-upload")[0].value = null;
                                        rmd_status.text('');
                                        rmd_status.hide();
                                    });

                                // keep selected file, in case repeatedly importing is helpful
                                // but do reset Import button!
                                dialog.data("reset", function() {
                                    notebook = null;
                                    ui_utils.disable_bs_button(import_button);
                                });
                                return dialog;
                            }
                            var dialog = $("#import-jupyter-file-dialog");
                            if(!dialog.length)
                                dialog = create_import_file_dialog();
                            else
                                dialog.data().reset();
                            dialog.modal({keyboard: true});

                        }       // action

                    },          // jupImport

                    jupExport: {
                        sort: 11002,
                        text: 'Export as Jupyter Notebook',
                        modes: ['edit'],
                        action: function() {

                            oc.exportIpynb(shell.gistname(), shell.version()).then(function(jup) {

                                if (jup === null) { jup = ''; }
                                download_as_file(jup.description + '.ipynb', jup.jup, 'text/json');
                            });
                        }
                    }

                });
            }

            k()

        }
    };

})());
