"""
Fabric script for deploying Plone consistently.
"""

from __future__ import with_statement
from fabric.api import *


def chicken():
    """
    Settings for the plone server.
    """

    # If your buildout file for QA is qa.cfg, the following line is correct:
    env.buildout_config = 'deployment.cfg'

    # A list of hostnames to deploy on. The following will try to connect to

    env.gateway = 'larreategi@silverfish.eea.europa.eu'
    env.hosts = []

    # The deploy user. Most deploy commands will be run as this user.
    env.deploy_user = 'zope'

    # The root of your Plone instance.
    env.directory = '/var/local/bise/bise.plonebuildout'
    env.hosts = ['larreategi@chicken.eea.europa.eu']


def _with_deploy_env(commands=[], use_sudo=True):
    """
    Run a set of commands as the deploy user in the deploy directory.
    """
    with cd(env.directory):
        for command in commands:
            if use_sudo:
                sudo(command, user=env.deploy_user)
            else:
                run(command)


def touch():
    _with_deploy_env(['touch mikel2.txt'])


def tail():
    _with_deploy_env(['tail -f var/log/www1.log'], use_sudo=False)


def pull():
    """
    Do a git pull.
    """
    env.forward_agent = True
    _with_deploy_env(['git pull origin master'], use_sudo=False)


def stop():
    """
    Shutdown the instance and zeo.
    """
    _with_deploy_env(['./bin/www1 stop', './bin/www2 stop', './bin/www3 stop'])


def start():
    """
    Start up the instance and zeo.
    """
    _with_deploy_env(['./bin/www1 start', './bin/www2 start', './bin/www3 start'])


def restart():
    """
    Restart just the zope instance, not the zeo.
    """
    _with_deploy_env(['./bin/www1 restart', './bin/www2 restart', './bin/www3 restart'])


def status():
    """
    Find out the running status of the server and deploy.
    """

    # General health of the server.
    run('uptime')

    # Deploy and running status
    _with_deploy_env(['./bin/www1 status',
                      './bin/www2 status',
                      './bin/www3 status',
                      'git log -1'])


def buildout():
    """
    Rerun buildout.
    """
    _with_deploy_env(['./bin/buildout -c %s -vv' % env.buildout_config])


def deploy():
    """
    Update code on the server and restart zope.
    """
    pull()
    stop()
    buildout()
    start()


def extra():
    """ Should normally just contain 'pass'. Useful for
        testing individual commands before integrating them into
        another function.
    """
    pass
