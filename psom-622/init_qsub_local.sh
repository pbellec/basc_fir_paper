# .bashrc

# User specific aliases and functions

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi
source /opt/share/mni/init.sh
unset MINC_FORCE_V2
export SGE_ROOT=/opt/N1GE6
export PATH=$PATH:/opt/N1GE6/bin/lx24-amd64
export PATH=$PATH:/usr/local/bin
