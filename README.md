Source code to accompany:

A mutual information approach to automate identification of neuronal clusters in Drosophila brain images
Nicolas Y. Masse, Sebastian Cachero, Aaron D. Ostrovsky, Gregory S. X. E. Jefferis
Division of Neurobiology, MRC Laboratory of Molecular Biology, Cambridge, CB2 0QH, UK.

Easy Installation
=================
Start Matlab and paste in the following code:

    tempscript=[tempname() '_fccinstall.m'];
    urlwrite('https://raw.github.com/jefferis/FruCloneClustering/master/src/Easy_Install_Masse.m',tempscript);
    run(tempscript);
    delete(tempscript);
    cd(fullfile(final_src_path,'src'));

(This saves the [`Easy_Install_Masse.m`][easyinstall] script to a local temporary file, runs it, removes it and then changes directory to the newly downloaded source code – all because matlab apparently cannot run a script from a url).
See [`src/Contents.m`][contents] for details of Matlab code and how to install additional dependencies of the full image processing pipeline.

Developer Installation
======================
If you want to keep up to date with the codebase/contribute, then you need to install [git](http://git-scm.com/).

Then in the shell:

    cd /some/sensible/dir
    git clone http://github.com/jefferis/FruCloneClustering.git
    git clone http://github.com/jefferis/MatlabSupport.git

In Matlab:

* Add FruCloneClustering/src and the whole of MatlabSupport to your path (IMPORTANT!)
* Run FruCloneClustering/Easy_Compile_Masse.m

Examples
========

See [`score_trace_wrapper.m`][stw] for examples of querying the database of fruitless clones with a traced neuron. These examples are part of the  function help that can be displayed by typing `help score_trace_wrapper` in Matlab.

[easyinstall]: https://github.com/jefferis/FruCloneClustering/blob/master/src/Easy_Install_Masse.m
[contents]: https://github.com/jefferis/FruCloneClustering/blob/master/src/Contents.m
[stw]: https://github.com/jefferis/FruCloneClustering/blob/master/src/score_trace_wrapper.m