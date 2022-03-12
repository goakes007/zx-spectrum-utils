"""
This module converts a regular graphic into an interlaced graphic
"""
import helper
from sprite import Sprite
LOG = helper.log_from_file_path(__file__)


def run():
    """
    This module converts a regular graphic into an interlaced graphic
    :return: n/a
    """
    sprite_x0_y0 = "$06, $00, $3e, $00, $7c, $00, $34, $00, $3e, $00, $3c, $00, $18, $00, $3c, $00, " \
                   "$7e, $00, $7e, $00, $f7, $00, $fb, $00, $3c, $00, $76, $00, $6e, $00, $77, $00"
    sprite_list = [sprite_x0_y0]
    sprite = Sprite()
    width = 2

    for sprite_str in sprite_list:
        sprite.read_dbs(sprite_str, width)
        interlace_sprite = sprite.create_interlace_sprite()
        dbs = interlace_sprite.write_dbs()
        print(f"    db {dbs} ; size {int((len(dbs)+1)/4)}")
    print()

    asm = helper.file_to_list("samples/mm_sprites.asm")
    file = ""
    print_next = False
    for line in asm:
        cnt = len(line.split(','))
        if print_next:
            print(file)
            print("    db 2,16")
            sprite.read_dbs(sprite_str, width)
            interlace_sprite = sprite.create_interlace_sprite()
            dbs = interlace_sprite.write_dbs()
            print(f"    db {dbs} ; size {int((len(dbs)+1)/4)}")
            print("  " + line)
            print_next = False

        if line[-1:] == ":":
            file = line
        if cnt > 5:
            sprite_str = line[5:]
            print_next = True


if __name__ == "__main__":
    run()
