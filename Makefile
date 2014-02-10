
OUT_DIR = bin/BSD-release

clean:
		rm -rf $(OUT_DIR)

ON-OFF-gen: main.c gengeo.h clean; mkdir -p $(OUT_DIR)
		cc -o $(OUT_DIR)/ON-OFF-gen main.c gengeo.c -lm
