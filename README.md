spt3g_cutter
================

Software for the SPT-3G thumbnail cutout service.

Local development
------------------

Path setup:

```bash
source /opt/miniconda3/bin/activate base
source ~/spt3g-devel/spt3g_cutter/setpath.sh ~/spt3g-devel/spt3g_cutter
```

Example usage:

```bash
spt3g_cutter ~/spt3g-dummy.csv --dbname /data/spt3g/dblib/spt3g.db --outdir .  --date_start 2020-01-01 --date_end 2021-06-30  --bands 150GHz --np 16 --yearly yearly_winter_2020
```

Docker
------------------

### Build Docker image

The Docker image is based on CentOS, using Conda to install the Python packages. The script below shows an example of how to build the image

```bash
export SPT3G_CUTTER_VERSION=0.2.1
export IMAGE_REPO=spt-cutter
docker build -t ${IMAGE_REPO}:${SPT3G_CUTTER_VERSION} --build-arg SPT3G_CUTTER_VERSION .
```

### Run Docker image

```bash
$ docker run -ti --rm --name spt-cutter \
    registry.gitlab.com/spt3g/kubernetes/spt-cutter:0.2.1 \
    spt3g_cutter --help

Starting conda env from: /home/sptworker/miniconda
Adding: /home/sptworker/miniconda/spt3g_cutter to paths
...
usage: spt3g_cutter [-h] [-c CONFIGFILE] [--inputList INPUTLIST] ...
                    [--bands [BANDS [BANDS ...]]] [--date_start  ...
                    [--log_format_date LOG_FORMAT_DATE] [--np NP]...
```
