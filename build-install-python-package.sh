export NODE_OPTIONS=--max_old_space_size=4096
pip install -e .[testing,dev]
npm install
npm run build
python setup.py sdist
python setup.py install