# Credit for ROOTDIR implementation:
# kenorb (https://stackoverflow.com/users/55075/kenorb),
# How to get current relative directory of your Makefile?,
# URL (version: 2017-05-23): https://stackoverflow.com/a/35698978
ROOTDIR			=	$(abspath $(patsubst %/,%,$(dir $(abspath $(lastword 		\
					$(MAKEFILE_LIST))))))

RM				=	rm
COPY			=	cp
FIND			=	find

HOMEWORK		=	homework06

CONDA			=	conda
CONDA_ENV_FILE	=	environment.yml
CONDA_ENV_NAME	=	cds411

PY				?=	python3
PY_SETUP		=	setup.py

JUPYTER			=	jupyter
JUPYTER_NB		=	$(HOMEWORK).ipynb
NBCONVERT_OPTS	=	--execute --config jupyter_notebook_config.py

BUILD_DIR		=	$(ROOTDIR)/build

define makefile_help
	@echo 'Makefile for Homework 6                                                   '
	@echo '                                                                          '
	@echo 'Usage:                                                                    '
	@echo '   make help                           display this message (default)     '
	@echo '                                                                          '
	@echo '   make clean                          remove temporary and build files   '
	@echo '   make all                            export Jupyter nb to all formats   '
	@echo '   make env                            create conda venv and install deps '
	@echo '   make pdf                            export Jupyter nb to PDF format    '
	@echo '   make rst                            export Jupyter nb to RST format    '
	@echo '                                                                          '
endef

define setup_build_directory
	mkdir -p "$@"
endef

define cleanup
	[ ! -d $(BUILD_DIR) ] || $(RM) -rf $(BUILD_DIR)
	$(FIND) -name "__pycache__" -type d -exec $(RM) -rf {} +
	$(FIND) -name ".ipynb_checkpoints" -type d -exec $(RM) -rf {} +
endef

define install_deps
	bash -lc "																	\
	$(CONDA) activate $(CONDA_ENV_NAME) &&										\
	$(PY) -m nb_pdf_template.install --minted									\
	"
endef

define launch_jupyter_lab
	bash -lc "																	\
	$(CONDA) activate $(CONDA_ENV_NAME) &&										\
	$(JUPYTER) lab --ip='0.0.0.0'												\
	"
endef

define nbconvert
	bash -lc "																	\
	$(CONDA) activate $(CONDA_ENV_NAME) &&										\
	$(JUPYTER) nbconvert --to $(1) $(NBCONVERT_OPTS) $(2)						\
	"
endef

define publish_docs
	git add $(BUILD_DIR)/$(HOMEWORK).rst
	git add $(BUILD_DIR)/$(HOMEWORK).pdf
	git commit -m "Homework submission exported to PDF and RST formats"
	git push origin master
endef

define nbconvert_travis
	$(JUPYTER) nbconvert --to $(1) $(NBCONVERT_OPTS) $(2)
endef

define update_conda_env
	bash -lc "$(CONDA) env update --file $(CONDA_ENV_FILE)"
endef

help :
	$(call makefile_help)

all : pdf rst

clean :
	$(call cleanup)

env :
	$(call update_conda_env)
	$(call install_deps)

lab :
	$(call launch_jupyter_lab)

pdf : $(BUILD_DIR)
	$(call nbconvert,pdf,$(JUPYTER_NB))

publish :
	$(call publish_docs)

rst : $(BUILD_DIR)
	$(call nbconvert,rst,$(JUPYTER_NB))

travis_build :
	$(call nbconvert_travis,rst,$(JUPYTER_NB))
	$(call nbconvert_travis,pdf,$(JUPYTER_NB))

$(BUILD_DIR) :
	$(call setup_build_directory)

.PHONY : help clean env pdf rst
