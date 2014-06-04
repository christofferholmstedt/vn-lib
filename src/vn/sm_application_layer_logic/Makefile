.PHONY: clean
.PHONY: all

ubuntu: all

ravenscar: clean
	echo "pragma Profile(Ravenscar);" > project_pragmas
	gnatmake -d -p -P sm_application_layer_logic.gpr

restricted: clean
	echo "pragma Profile(Restricted);" > project_pragmas
	gnatmake -d -p -P sm_application_layer_logic.gpr

all: clean
	echo "" > project_pragmas
	gnatmake -d -p -P sm_application_layer_logic.gpr

clean:
	-gnat clean -P sm_application_layer_logic.gpr

clean-all:
	gnat clean -r -P sm_application_layer_logic.gpr
