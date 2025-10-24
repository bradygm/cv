# Makefile to build PDF and Markdown cv from YAML.
#
# Brandon Amos <http://bamos.github.io> and
# Ellis Michael <http://ellismichael.com> and
# Brady Moon <http://bradymoon.com>


TEMPLATES=$(shell find templates -type f)

BUILD_DIR=build
TEX=$(BUILD_DIR)/cv.tex
PDF=$(BUILD_DIR)/cv.pdf
MD=$(BUILD_DIR)/cv.md
DOCKERFILE=Dockerfile

IMAGE = py-jinja
IMAGE_STAMP = $(BUILD_DIR)/.py-jinja.stamp

ifneq ("$(wildcard cv.hidden.yaml)","")
	YAML_FILES = cv.yaml cv.hidden.yaml
else
	YAML_FILES = cv.yaml
endif

.PHONY: all public viewpdf stage jekyll push clean

all: $(PDF) $(MD) viewpdf

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(IMAGE_STAMP): Dockerfile requirements.txt
	mkdir -p $(BUILD_DIR)
	docker build -t $(IMAGE) -f $(DOCKERFILE) .
	touch $(IMAGE_STAMP)

# public: $(BUILD_DIR) $(TEMPLATES) $(YAML_FILES) generate.py
# # 	./generate.py cv.yaml
# 	docker run --rm -v "$$PWD":/app -w /app py-jinja 

$(TEX) $(MD): $(IMAGE_STAMP) $(TEMPLATES) $(YAML_FILES) generate.py publications/*.bib
	docker run --rm -v "$$PWD":/app -w /app $(IMAGE)

$(PDF): $(TEX)
	docker run --rm -v "$$PWD":/work -w /work --user "$(id -u):$(id -g)" texlive/texlive:latest bash -lc "latexmk -pdf -jobname=build/cv -interaction=nonstopmode -halt-on-error build/cv && latexmk -c -jobname=build/cv build/cv"

viewpdf: $(PDF)
	open $(PDF)

clean:
	rm -rf *.db $(BUILD_DIR)/cv*

test:
	echo "No tests defined."
