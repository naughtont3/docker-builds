
# TJN: I just use a single install dir
my_install_dir=/usr/local

oshmem_install_dir=${my_install_dir}
orte_install_dir=${my_install_dir}
ucx_install_dir=${my_install_dir}
pmix_install_dir=${my_install_dir}

oshmem_bin_path=${oshmem_install_dir}/bin
oshmem_lib_path=${oshmem_install_dir}/lib

orte_bin_path=${orte_install_dir}/bin
orte_lib_path=${orte_install_dir}/lib

ucx_bin_path=${ucx_install_dir}/bin
ucx_lib_path=${ucx_install_dir}/lib

pmix_bin_path=${pmix_install_dir}/bin
pmix_lib_path=${pmix_install_dir}/lib

#### END CONFIG ####

if ! `echo $PATH | grep -q ${orte_bin_path}` ; then
    export PATH="${orte_bin_path}:$PATH"
fi
if [ "x$LD_LIBRARY_PATH" == "x" ] ; then
    export LD_LIBRARY_PATH="${orte_lib_path}"
else
    if ! `echo $LD_LIBRARY_PATH | grep -q ${orte_lib_path}` ; then
        export LD_LIBRARY_PATH="${orte_lib_path}:$LD_LIBRARY_PATH"
    fi
fi


if ! `echo $PATH | grep -q ${ucx_bin_path}` ; then
    export PATH="${ucx_bin_path}:$PATH"
fi
if [ "x$LD_LIBRARY_PATH" == "x" ] ; then
    export LD_LIBRARY_PATH="${ucx_lib_path}"
else
    if ! `echo $LD_LIBRARY_PATH | grep -q ${ucx_lib_path}` ; then
        export LD_LIBRARY_PATH="${ucx_lib_path}:$LD_LIBRARY_PATH"
    fi
fi


if ! `echo $PATH | grep -q ${pmix_bin_path}` ; then
    export PATH="${pmix_bin_path}:$PATH"
fi
if [ "x$LD_LIBRARY_PATH" == "x" ] ; then
    export LD_LIBRARY_PATH="${ucx_lib_path}"
else
    if ! `echo $LD_LIBRARY_PATH | grep -q ${ucx_lib_path}` ; then
        export LD_LIBRARY_PATH="${ucx_lib_path}:$LD_LIBRARY_PATH"
    fi
fi


if ! `echo $PATH | grep -q ${oshmem_bin_path}` ; then
    export PATH="${oshmem_bin_path}:$PATH"
fi
if [ "x$LD_LIBRARY_PATH" == "x" ] ; then
    export LD_LIBRARY_PATH="${ucx_lib_path}"
else
    if ! `echo $LD_LIBRARY_PATH | grep -q ${ucx_lib_path}` ; then
        export LD_LIBRARY_PATH="${ucx_lib_path}:$LD_LIBRARY_PATH"
    fi
fi

