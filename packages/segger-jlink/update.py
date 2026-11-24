#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3 python3Packages.beautifulsoup4 python3Packages.requests

import random
import subprocess
from collections import namedtuple
from pathlib import Path
from tempfile import NamedTemporaryFile
from textwrap import dedent, indent

import requests
from bs4 import BeautifulSoup

Arch = namedtuple('Architecture', ['os', 'name', 'ext'])
ARCH_MAP = {
    'x86_64-linux': Arch(os='Linux', name='x86_64', ext='tgz'),
    'i686-linux': Arch(os='Linux', name='i386', ext='tgz'),
    'aarch64-linux': Arch(os='Linux', name='arm64', ext='tgz'),
    'armv7l-linux': Arch(os='Linux', name='arm', ext='tgz'),
    'aarch64-darwin': Arch(os='MacOSX', name='arm64', ext='pkg'),
}

def user_agent():
    '''
    Popular user agents, randomized
    :return: {'User-Agent':'some_agent'}
    '''
    headers = ['Mozilla/5.0 (Windows NT 6.1; WOW64; rv:41.0) Gecko/20100101 Firefox/41.0',
               'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36',
               'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36',
               'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36',
               'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11) AppleWebKit/601.1.56 (KHTML, like Gecko) Version/9.0 Safari/601.1.56',
               'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36',
               'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/601.2.7 (KHTML, like Gecko) Version/9.0.1 Safari/601.2.7',
               'Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko',
               'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:41.0) Gecko/20100101 Firefox/41.0',
               'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:41.0) Gecko/20100101 Firefox/41.0',
               'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:41.0) Gecko/20100101 Firefox/41.0',
               'Mozilla/5.0 (Windows NT 6.3; WOW64; rv:41.0) Gecko/20100101 Firefox/41.0',
               'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:41.0) Gecko/20100101 Firefox/41.0',
               'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36',
               'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36',
               'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36',
               'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36',
               'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36',
               'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36',
               'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36',
               'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36',
               'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36',
               'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:51.0) Gecko/20100101 Firefox/51.0',
               ]
    return {'User-Agent': headers[random.randrange(0, len(headers))]}

def find_latest_jlink_version() -> str:
    try:
        response = requests.get('https://www.segger.com/downloads/jlink/', headers=user_agent())
        response.raise_for_status()
    except requests.RequestException as e:
        raise RuntimeError(f"Error fetching J-Link version: {e}")

    soup = BeautifulSoup(response.text, 'html.parser')

    jlink_download_tile = soup.find(lambda tag: tag.name == 'tbody' and "J-Link Software and Documentation Pack" in tag.text)
    version_select = jlink_download_tile.find('select')
    version = next(o.text for o in version_select.find_all('option'))

    if version is None:
        raise RuntimeError("Could not find the J-Link version on the download page.")

    return version.removeprefix('V').replace('.', '')


def nar_hash(version: str, arch: Arch) -> str:
    '''
    Return the nar hash of 'version' for 'source'.
    '''
    url = f"https://www.segger.com/downloads/jlink/JLink_{arch.os}_V{version}_{arch.name}.{arch.ext}"
    try:
        response = requests.post(url, data={'accept_license_agreement': 'accepted'}, headers=user_agent())
        response.raise_for_status()
    except requests.RequestException as e:
        raise RuntimeError(f"Error downloading file from {url}: {e}")

    with NamedTemporaryFile() as tmpfile:
        tmpfile.write(response.content)
        tmpfile.flush()
        output = subprocess.check_output([
            "nix",
            "--extra-experimental-features", "nix-command",
            "hash", "file", "--sri", tmpfile.name
        ]).decode("utf8")

    return output.strip()


def update_source(version: str):
    content = f'version = "{version}";\n'
    for arch_nix, arch in ARCH_MAP.items():
        nhash = nar_hash(version, arch)
        content += dedent(f'''
        {arch_nix} = {{
          os = "{arch.os}";
          name = "{arch.name}";
          ext = "{arch.ext}";
          hash = "{nhash}";
        }};''').strip() + '\n'

    content = '{\n' + indent(content, '  ') + '}\n'

    with open(Path(__file__).parent / 'source.nix', 'w') as file:
        file.write(content)


if __name__ == '__main__':
    update_source(find_latest_jlink_version())
