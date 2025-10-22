# Makefile to use the filelists defined in other mk files

BUILD_DIR = build

# Verbose mode for make (print commands as they are executed)
VERBOSE=0

# Create the build directory if it does not exist
$(BUILD_DIR):
	mkdir -p $@

# Create a seperate filelist for each group of files
.PHONY: filelist
filelist: $(BUILD_DIR)
	@cd $(BUILD_DIR)
	@echo "Generating filelists in $(BUILD_DIR)..."
	@echo "# Filelist for $(TOP_MODULE)" > $(BUILD_DIR)/filelist.f
	@echo "# Include directories" >> $(BUILD_DIR)/filelist.f
	@for dir in $(INCLUDE_DIRS); do \
		echo "+incdir+$$dir" >> $(BUILD_DIR)/filelist.f; \
	done
	@echo "" >> $(BUILD_DIR)/filelist.f
	@echo "# Package Files" >> $(BUILD_DIR)/filelist.f
	@for file in $(PKG_FILES); do \
		echo "../$$file" >> $(BUILD_DIR)/filelist.f; \
	done
	@echo "" >> $(BUILD_DIR)/filelist.f
	@echo "# Verilog RTL Files" >> $(BUILD_DIR)/filelist.f
	@for file in $(VERILOG_RTL_FILES); do \
		echo "../$$file" >> $(BUILD_DIR)/filelist.f; \
	done

	@echo "# Verilog Testbench Files" > $(BUILD_DIR)/tb_filelist.f
	@for file in $(VERILOG_TB_FILES); do \
		echo "../$$file" >> $(BUILD_DIR)/tb_filelist.f; \
	done
	@echo "Filelists generated successfully."

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
