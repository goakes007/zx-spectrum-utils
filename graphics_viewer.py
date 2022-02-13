"""
This program will allow the user to covert a zx spectrum file into a viewable graphic viewer
in the aid to try and find graphics that they might be interested in looking at or using
"""
import pygame
import image_lib as il
import memory
import helper
LOG = helper.log_from_file_path(__file__)

SCREEN_SIZE = [1000, 800]
FRAMES_PER_SECOND = 30

####################################################################
# MAIN
####################################################################


def run():
    """
    This function is the main function of the program to run the program
    :return: n/a
    """
    pygame.init()
    clock = pygame.time.Clock()
    screen = pygame.display.set_mode(SCREEN_SIZE)
    pygame.display.set_caption("Graphics Viewer")

    memory_pointer = 0x8200
    memory_pointer_increase = 256
    filename = "C:/GRAHAM/manic.sna"

    done = False                            # Time to quit?
    snap_memory = ""                        # Initialise the zx spectrum memory
    _filename = ""                          # remember the old value of filename to check that it has changed
    _memory_pointer = 0                     # remember the old value of memory_pointer to check that it has changed
    _memory_pointer_increase = 0            # remember the old value of memory_pointer_increase to check that it has changed
    memory_pointer_key_plus = False         # Was the pageup/down pressed?
    ofx = 52; ofy = 100                     # Offsets screen position
    cx1 = 220; cx2 = 270; cx3 = 320; cx4 = 390; cx5 = 460   # Columns screen positions
    show_moving_graphic = False             # Show moving graphic varaibles
    smg_image_count = 4
    _smg_image_count = 0
    smg_index = 0
    smgx = smgy = 0
    smg_sx = 620; smg_sy = 295

    while not done:
        clock.tick(FRAMES_PER_SECOND)

        for event in pygame.event.get():  # User did something
            LOG.debug(f"[Stack Pointer:{memory_pointer}] - event:{event}")
            if event.type == pygame.QUIT:  # If user clicked close
                done = True  # Flag that we are done so we exit this loop
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_UP: memory_pointer_key_plus = 1
                if event.key == pygame.K_DOWN: memory_pointer_key_plus = -1

            if event.type == pygame.KEYUP:
                if event.key == pygame.K_q: done = True
                if event.key == pygame.K_ESCAPE: done = True
                if event.key == pygame.K_UP: memory_pointer_key_plus = 0
                if event.key == pygame.K_DOWN: memory_pointer_key_plus = 0

                if event.key == pygame.K_PAGEUP: memory_pointer_increase *= 2
                if event.key == pygame.K_PAGEDOWN: memory_pointer_increase = int(memory_pointer_increase / 2)
                if event.key == pygame.K_LEFT: memory_pointer -= 1
                if event.key == pygame.K_RIGHT: memory_pointer += 1
                if event.key == pygame.K_f: filename = memory.prompt_file()
                if event.key == pygame.K_d: memory.dump_graphics_dbs(filename, snap_memory, memory_pointer, smgx, smgy, smg_image_count)

                if event.key >= pygame.K_1 and event.key <= pygame.K_8:
                    smg_image_count = event.key - pygame.K_0

            if event.type == pygame.MOUSEBUTTONDOWN:
                scn_x, scn_y = event.pos
                LOG.info(f"Mouse pressed {event.pos} {scn_x}/{scn_y} - event({event})")
                # Was one of the green numbers pressed?
                if scn_y >= ofy and scn_y <= ofy + 40 * 16:
                    if scn_x >= ofx and scn_x < ofx + (8 * 20):
                        line_x = scn_x - ofx; line_y = scn_y - ofy
                        char_x = int(line_x / 20); char_y = int(line_y / 16)
                        LOG.info(f"char_x/y {char_x}/{char_y}")
                        memory_pointer += char_x + char_y * 8
                # check for column 1,2,3,4,5
                if scn_x > cx1 and scn_x < cx1 + 8 * 2: memory.dump_column_dbs(filename, snap_memory, memory_pointer, 1)
                if scn_x > cx2 and scn_x < cx2 + 16 * 2: memory.dump_column_dbs(filename, snap_memory, memory_pointer, 2)
                if scn_x > cx3 and scn_x < cx3 + 24 * 2: memory.dump_column_dbs(filename, snap_memory, memory_pointer, 3)
                if scn_x > cx4 and scn_x < cx4 + 32 * 2: memory.dump_column_dbs(filename, snap_memory, memory_pointer, 4)
                if scn_x > cx5 and scn_x < cx5 + 64 * 2: memory.dump_column_dbs(filename, snap_memory, memory_pointer, 8)
                # Was the show moving graphic pressed?
                if scn_y >= smg_sy and scn_y <= smg_sy + (20 * 8):
                    if scn_x >= smg_sx and scn_x < smg_sx + (8 * 25):
                        line_x = scn_x - smg_sx; line_y = scn_y - smg_sy
                        smgx = int(line_x / 25) + 1; smgy = int(line_y / 20) + 1
                        LOG.info(f"moving graphic x/y {smgx}/{smgy}")
                        show_moving_graphic = True

            if event.type == pygame.MOUSEBUTTONUP:
                show_moving_graphic = False

        memory_pointer_increase = max(memory_pointer_increase, 1)
        memory_pointer_increase = min(memory_pointer_increase, 2048)

        # Updates
        update_window = False
        if show_moving_graphic: update_window = True
        if _filename != filename:
            (filename, snap_memory) = memory.read_binary_file(filename)
            LOG.info(f"New file: {filename}")
            LOG.info(f"Size of memory loaded is {len(snap_memory)}")
            _filename = filename
            update_window = True
        if memory_pointer_key_plus:
            memory_pointer += memory_pointer_increase * memory_pointer_key_plus
            memory_pointer = max(memory_pointer, 0)
            memory_pointer = min(memory_pointer, 0x10000)
        if _memory_pointer != memory_pointer:
            update_window = True
            _memory_pointer = memory_pointer
        if _memory_pointer_increase != memory_pointer_increase:
            update_window = True
            _memory_pointer_increase = memory_pointer_increase
        if _smg_image_count != smg_image_count:
            update_window = True
            _smg_image_count = smg_image_count

        if update_window:
            # Draw
            LOG.info("Performing an update")
            screen.fill(il.WHITE)  # Clear the screen and set the screen background
            il.draw_text(screen, il.BLUE, (10, 20), f"Memory: {memory.short_hex(memory_pointer)}     increase:{memory_pointer_increase}", size=30)
            if len(filename) < 50: il.draw_text(screen, il.BLUE, (10, 45), f"File: {filename}", size=25)
            else:
                il.draw_text(screen, il.BLUE, (10, 45), f"File: {filename[:50]}", size=25)
                il.draw_text(screen, il.BLUE, (20, 70), f"{filename[50:]}", size=25)

            for (scn_x, txt) in [(cx1, "8"), (cx2, "16"), (cx3, "24"), (cx4, "32"), (cx5, "64")]:
                il.draw_text(screen, il.BLUE, (scn_x + 2, 82), f"{txt}", size=22)

            y_off = 40  # y offset for keys / mouse text
            il.draw_text(screen, il.BLUE, (610, y_off + 0), "Keys", size=25)
            il.draw_text(screen, il.BLUE, (615, y_off + 20), "Up/down - change memory pointer by memory increase", size=20)
            il.draw_text(screen, il.BLUE, (615, y_off + 40), "Left/Right - change memory pointer by 1", size=20)
            il.draw_text(screen, il.BLUE, (615, y_off + 60), "Page Up/down - change memory increase", size=20)
            il.draw_text(screen, il.BLUE, (615, y_off + 80), "f - Read a new file", size=20)
            il.draw_text(screen, il.BLUE, (615, y_off + 100), "d - show assember DBs for moving image", size=20)
            il.draw_text(screen, il.BLUE, (615, y_off + 120), "1..8 - change show image count", size=20)
            il.draw_text(screen, il.BLUE, (615, y_off + 140), "q - Quit", size=20)

            il.draw_text(screen, il.BLUE, (610, y_off + 155), "Mouse", size=25)
            il.draw_text(screen, il.BLUE, (615, y_off + 175), "Click green number - changes memory pointer", size=20)
            il.draw_text(screen, il.BLUE, (615, y_off + 195), "Click image column - Creates Assember DBs", size=20)

            il.draw_text(screen, il.BLUE, (615, y_off + 215), "Show moving image, click red size below", size=20)
            il.draw_text(screen, il.BLUE, (615, y_off + 235), f"Image Count: {smg_image_count}      [{smg_index},{smgx}/{smgy}]", size=20)
            for x_size in range(1, 9):
                for y_size in range(1, 9):
                    il.draw_text(screen, il.RED, (smg_sx + (x_size - 1) * 25, smg_sy + (y_size - 1) * 20), f"{x_size}x{y_size}", size=20)

            # Display some offsets and memopry values
            rows = 320
            for i in range(0, rows, 8):
                mem_ptr = memory_pointer + i
                il.draw_text(screen, il.BLACK, (24, 100 + (i * 2)), f"{memory.short_hex(mem_ptr)}", size=16)
                for j in range(0, 8):
                    mem_ptr2 = mem_ptr + j
                    if mem_ptr2 < len(snap_memory):
                        peek = snap_memory[mem_ptr2]
                        il.draw_text(screen, il.GREEN, (ofx + (j * 20), ofy + (i * 2)), f"{memory.short_hex(peek)}", size=16)

            il.show_graphics(screen, snap_memory, memory_pointer, 1, rows, cx1, 100)
            il.show_graphics(screen, snap_memory, memory_pointer, 2, rows, cx2, 100)
            il.show_graphics(screen, snap_memory, memory_pointer, 3, rows, cx3, 100)
            il.show_graphics(screen, snap_memory, memory_pointer, 4, rows, cx4, 100)
            il.show_graphics(screen, snap_memory, memory_pointer, 8, rows, cx5, 100)

            if show_moving_graphic:
                smg_index += 1
                if smg_index >= smg_image_count: smg_index = 0
                mem_ptr = memory_pointer + smg_index * smgx * smgy * 8
                il.show_graphics(screen, snap_memory, mem_ptr, smgx, smgy * 8, 620, 460, size=4)

            pygame.display.flip()

    pygame.quit()


if __name__ == "__main__":
    run()
