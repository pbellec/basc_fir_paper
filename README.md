basc_fir_paper
==============

This github repository is a companion for the following publication:

_The richness of task-evoked hemodynamic responses defines a pseudo-hierarchy of functionally meaningful brain networks_

P. Orban<sup>1,2</sup> J. Doyon<sup>1,3</sup> M. Petrides<sup>6</sup> M. Mennes<sup>7,8</sup> R. Hoge<sup>1,4</sup> P. Bellec<sup>1,5</sup>

  <sup>1</sup>Functional Neuroimaging Unit, Centre de Recherche de l'Institut Universitaire de Gériatrie de Montréal  
  <sup>2</sup>Department of Psychiatry  
  <sup>3</sup>Department of Psychology  
  <sup>4</sup>Department of Physiology and Biomedical Engineering  
  <sup>5</sup>Department of Computer Science and Operations Research, University of Montreal, Montreal, Quebec, Canada  
  <sup>6</sup>Cognitive Neuroscience Unit, Montreal Neurological Institute, McGill University, Montreal, Quebec, Canada  
  <sup>7</sup>Department of Cognitive Neuroscience, Radbout University Nijmegen Medical Center  
  <sup>8</sup>Donders Institute for Brain, Cognition and Behavior, Radbout University Nijmegen, Nijmegen, The Netherlands  

For all question regarding the paper, please address correspondence to Pierre Orban, CRIUGM, 4545 Queen Mary, Montreal, QC, H3W 1W5, Canada. Email: pierre.orban (at) criugm.qc.ca. The method and code are developed by Pierre Bellec, same address. Email: pierre.bellec (at) criugm.qc.ca

Disclaimer
----------

This is a snapshot of the development librairies of the [SIMEXP laboratory](http://www.simexp-lab.org) at the time of production (12/2011) of the results reported in the paper. This code is not meant as a toolbox for public use. It is not documented, and many of the options are non-functional or have not been tested. This is a research-grade code, meant to clarify the details of implementation of the algorithms described in the aforementioned paper. The BASC-FIR method will be made publicly available as part of the [NIAK](http://code.google.com/p/niak) package for the "boss" release scheduled in 2014.

Note that due to restrictions imposed by the local ethics review board at CRIUGM, it was not possible to publicly release the raw or preprocessed human imaging data used in the paper. It will thus not be possible for interested readers to exactly reproduce all published experiments. The authors apologize for the inconvenience, and are actively working on a solution for future publications.

License
----------

The library shared in this repository is an opensource project under an MIT license, reproduced hereafter : 

Permission is hereby granted, free of charge, to any person obtaining a copy 
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software. 
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
THE SOFTWARE. 

Content
-------

The repository includes several hundreds of functions, the majority being unrelated to the BASC-FIR project. All the code (or 99%, the remaining 1% being perl and shell scripts) is written in [Matlab](http://www.mathworks.com/) and also compatible with [Octave](http://www.gnu.org/software/octave/). For those trying to run the code, there are a number of dependencies that are covered in the [installation page](http://www.nitrc.org/plugins/mwiki/index.php/niak:Installation) of NIAK. Here is a list of key functions with associated documentation when available (all codes have in-code help, but only some of the pipelines have tutorials):
  * [niak_pipeline_fmri_preprocess](niak-1233/pipeline/niak_pipeline_fmri_preprocess.m): the pipeline to preprocess structural and fMRI datasets. This pipeline is using many other tools in the repository. You can read the on-line documentation on [NITRC](http://www.nitrc.org/plugins/mwiki/index.php/niak:FmriPreprocessing064) for more details on the workflow.
  * [niak_pipeline_region_growing](basc-714M/pipeline/niak_pipeline_region_growing.m): the region growing pipeline. Note that this is an old, unreleased code, with no recent documentation but for the in-code help. The [recent documenation](http://www.nitrc.org/plugins/mwiki/index.php/niak:RegionGrowing) for NIAK "ammo" should mostly apply though. The pipeline was not called directly, but through niak_pipeline_stability_fir (see below), which applied it on FIR estimates.
  * [niak_brick_fir](basc-714M/bricks/basc/niak_brick_fir.m): estimation of a finite-impulse response based on fMRI time series and a set of event times. 
  * [niak_brick_stability_fir](basc-714M/bricks/basc/niak_brick_stability_fir.m): the boostrap analysis of stable clusters for individual FIR data.
  * [niak_brick_stability_group](basc-714M/bricks/basc/niak_brick_stability_group.m): the boostrap analysis of stable clusters at the group level (based on the average stability matrix across all individuals.
  * [niak_brick_stability_maps](basc-714M/bricks/basc/niak_brick_stability_maps.m): generation of stability maps, stability cores and partitions threshold based on stability.
  * [niak_brick_fdr_fir](basc-714M/bricks/basc/niak_brick_fdr_fir.m): test the significance of average group-level FIR (against zero) for each cluster, as well as the significance of the difference in average FIR between each pair of networks. Tests are non-parametric, bootstrap based. Control for multiple comparisons is implemented through estimation of the false-discovery rate.
  * [niak_pipeline_stability_fir](basc-714M/pipeline/niak_pipeline_stability_fir.m): the multi-scale (as in different number of clusters), multi-level (as in individual, group, and consensus group) BASC analysis on FIR responses.
  * [niak_hierarchical_clustering](niak-1233/commands/clustering/niak_hierarchical_clustering.m): the code for hierarchical agglomerative clustering using the Ward's criterion, which is used both for individual BASC, group BASC and consensus group BASC.
  * [niak_msteps](basc-714M/commands/clustering/niak_msteps.m): the multiscale stepwise selection (MSTEPS) method to pick up representative numbers of clusters in a multiscale analysis.
   
Finally, the repository also includes the scripts that were used to call the pipelines:
  * [fir_fmri_preprocess](scripts_analysis/fir_fmri_preprocess.m): the script to preprocess the structural and functional data.
  * [fir_pipeline_roi](scripts_analysis/fir_pipeline_roi.m): the script to run the region growing pipeline on the task datasets.
  * [fir_pipeline_roi_rest](scripts_analysis/fir_pipeline_roi_rest.m): the script to run the region growing pipeline on the resting-state datasets.
  * [fir_pipeline_stabiliy_final](scripts_analysis/fir_pipeline_stability_final.m): the script to run the BASC-FIR analysis on the task dataset.
  * [fir_pipeline_stabiliy_rest](scripts_analysis/fir_pipeline_stability_rest.m): the script to run the BASC-FIR analysis on the resting-state dataset (negative control experiment, with various levels of judo noise).
