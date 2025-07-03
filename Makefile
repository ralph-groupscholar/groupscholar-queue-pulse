APP=gs-queue-pulse
SRC=src/queue_pulse.s
LIBDIR:=$(shell pg_config --libdir)

all: $(APP)

$(APP): $(SRC)
	clang -o $@ $(SRC) -L$(LIBDIR) -lpq -Wl,-rpath,$(LIBDIR)

clean:
	rm -f $(APP)
