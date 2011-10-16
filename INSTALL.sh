#!/bin/sh -x

workdir=`pwd`
tempdir=/tmp/INSTALL.$$

version=0.9.5.0
siteurl=http://releases.compiz.org/${version}

pkglist="
compiz
libcompizconfig
compiz-fusion-plugins-main
compiz-fusion-plugins-extra
compizconfig-backend-gconf
compizconfig-python
ccsm
emerald
"

for debian_package in `echo ${pkglist}`
do

	if echo ${debian_package} | grep -Eq '^#'
	then
		continue
	fi

        compiz_package=`echo ${debian_package} | sed 's/-fusion//g'`
        compiz_archive=${compiz_package}-${version}.tar.bz2

        debian_dirname=${debian_package}-${version}
        debian_archive=${debian_package}_${version}.orig.tar.gz

	cd ${workdir}
	if [ ! -e ${debian_dirname}/${debian_archive} ]
	then
		if [ ! -e releases/${compiz_archive} ]
		then
			mkdir -p releases
			if [ ${debian_package} != emerald ]
			then
				cd releases
				wget ${siteurl}/${compiz_archive} || exit 1
			else
				cd releases
				wget http://git.compiz.org/fusion/decorators/emerald/snapshot/emerald-0.9.5.tar.bz2 || exit 1
				mv emerald-0.9.5.tar.bz2 ${compiz_archive}
			fi
		fi

		rm -fr ${tempdir}
		mkdir -p ${tempdir}

		cd ${tempdir}
		tar jxf ${workdir}/releases/${compiz_archive}

		compiz_dirname=`ls | head -n 1`

		if [ ${compiz_dirname} != ${debian_dirname} ]
		then
			mv ${compiz_dirname} ${debian_dirname}
		fi
		tar zcf ${debian_archive} ${debian_dirname}

		mkdir -p ${workdir}/${debian_dirname}
		cd ${workdir}/${debian_dirname}

		mv ${tempdir}/${debian_archive} .
		tar zxf ${debian_archive}
	fi

	cd ${workdir}
	cd ${debian_dirname}/${debian_dirname}

        debuild -us -uc || exit 1
        sudo dpkg -i ../*.deb

done

rm -fr ${tempdir}

cd ${workdir}
sudo dpkg -i */*.deb

sudo dpkg --purge compiz-kde
