import os
import sys
from setuptools import setup, find_packages
import subprocess
from distutils.spawn import find_executable
import re


here = os.path.abspath(os.path.dirname(__file__))
README = open(os.path.join(here, 'README.md')).read()
CHANGES = open(os.path.join(here, 'CHANGES.md')).read()
VERSION_BYTES = subprocess.check_output("git describe --tags --match '[0-9]*'", shell=True).strip()
VERSION = str(VERSION_BYTES)


def verify_dependency(executable_name, min_version=None, suffix=None):
    '''
    Verify dependencies on non-python executables upon which some shell scripts in ssh-ecs-run-task rely
    '''
    executable = find_executable(executable_name)
    if not executable:
        sys.exit('You must install %s before installing ssh-ecs-run-task' % executable_name)
    else:
        if min_version or suffix:
            executable = os.path.abspath(executable)
            try:
                version_bytes = subprocess.check_output("%s --version" % executable,  stderr=None, shell=True).strip()
            except:
                sys.exit("Could not determine version of %s" % executable_name)

            version = str(version_bytes)

            if version == '':
                sys.exit("Could not determine version of %s" % executable_name)

            #print("version = '%s'" % version)
            m = re.match(r"[^0-9]*(?P<XYZ>\b[0-9]+\.[0-9\.]+)(?P<suffix>(\-[^\s]+|))\b", version)
            if not m:
                print("Unrecognized format for version string %s" % version)

            XYZ = m.group('XYZ')

            if XYZ == '':
                sys.exit("Could not determine version of %s" % executable_name)

            if min_version:
                version_nums = str.split(XYZ, '.')
                for idx, val in enumerate(str.split(min_version, '.')):
                    if idx >= len(version_nums) or int(val) > int(version_nums[idx]):
                        if exit:
                            sys.exit("You must upgrade %s to %s or higher" % (executable_name, min_version))
                        else:
                            print("WARNING: you should upgrade %s to %s or higher" % (executable_name, min_version))
            if suffix and version.find(suffix) == -1:
                sys.exit("Suffix %s was not found in version %s" % (suffix, version))



if __name__ == '__main__':
    print('Running setup.py for ssh-ecs-run-task version %s' % VERSION)
    # verify_dependency('ecs-cli', '0.4')
    verify_dependency('json', '9.0')


setup(
    name='ssh-ecs-run-task',
    version=VERSION,
    description='ssh-ecs-run-task -- the interactive task runner for ECS',
    long_description=README + '\n\n' + CHANGES,
    author='Mark Riggins',
    author_email='mark.riggins@SocialCodeInc.com',
    url='',
    keywords='SocialCode AWS Docker ECS ecs-cli Task TaskDefinition',
    install_requires=['PyYAML', 'awscli>1.10.53'],
    packages=find_packages(),
    scripts=[
        'ssh-ecs-log-task',
        'ssh-ecs-run-task',
        'ssh-ecs-stats-task',
    ],
    entry_points={
        'console_scripts': [],
    },
    options={
        'install': {
            'install_scripts': '/usr/local/bin'
        }
    }
)

