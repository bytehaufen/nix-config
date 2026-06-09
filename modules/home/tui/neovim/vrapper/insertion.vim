" doc-title: Insertion

" doc: Paste over selection without yanking replaced text
vnoremap p "_dP

" doc: Insert lorem ipsum paragraph
nnoremap <leader>iL    iLorem ipsum dolor sit amet, consectetuer adipiscing elit.  Donec hendrerit tempor tellus.  Donec pretium posuere tellus.  Proin quam nisl, tincidunt et, mattis eget, convallis nec, purus.  Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculous mus.  Nulla posuere.  Donec vitae dolor.  Nullam tristique diam non turpis.  Cras placerat accumsan nulla.  Nullam rutrum.  Name vestibulum accumsan nisl.<Esc>

" doc: Insert lorem ipsum sentence
nnoremap <leader>il    iLorem ipsum dolor sit amet, consectetuer adipiscing elit.

" doc: Insert snippet
eclipseaction insertion_snippet org.eclipse.ui.views.showView(org.eclipse.ui.views.showView.viewId=org.eclipse.ui.texteditor.TemplatesView)
nnoremap <leader>is    :insertion_snippet<cr>
