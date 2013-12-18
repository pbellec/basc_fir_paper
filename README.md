basc_fir_paper
==============

This git-hub repository is a companion to the following publication:

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

Content
-------

The repository includes several hundreds of functions, the majority being unrelated to the current project. Here is a list of key functions and associated analytical steps:
  * niak_brick_stability_fir: the boostrap analysis of stable clusters for individual FIR data.
  * To be continued


