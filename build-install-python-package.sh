export NODE_OPTIONS=--max_old_space_size=4096
rm -rf dash/deps
rm -rf dash-renderer/node_modules
pip install -e .[testing,dev]
npm install
npm run build.sequential
python setup.py sdist
python setup.py install