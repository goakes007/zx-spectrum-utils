"""
Sprites can be stored in many ways
A really cool way, is to have the image with an ANDable section so that the background is cleared before printing it.
This way it doesn't need to be xor'ed, but just ORed.
The AND section can be stored interlaced with the actual graphic for example:
        Before               After   AND part        Orginal part
        ....1111,...11...      111.....,.1....11     ....1111,...11...
        .....111,....1...      1111....,.11...11     .....111,....1...
    However the second image needs to be interlaced as  follows:

    After   AND part    Orginal part        | NOW Interlaced
    111.....,.1....11   ....1111,...11...   |   111.....,...11...,.1....11,...11...
    1111....,.11...11   .....111,....1...   |   1111....,.....111,.11...11,....1...
      AND1  , AND2        ORG1  , ORG2      |   AND1,ORG1,AND2,ORG2

During printing of the sprite, the route would first AND the first part then OR the original part

Q. How do we create the AND section?
A. Either by hand or write a program to do it.
This is the program to create the interlace sprite from the original sprite
"""

import helper
LOG = helper.log_from_file_path(__file__)


class Sprite:
    """
    This class holds all function used to manipulate a sprite.
        self.sprite = []                hex codes
        self.width = 0                  width of sprite, typeically 2
        self.zeros = '.'                character to be used during __str__ for zeros
        self.interlaced = False         Is the sprite interlaced yet or not
        self.add_extra_zeros = False    Add extra zeros between top and bottom used during interlace process
    """
    def __init__(self):
        self.sprite = []
        self.width = 0
        self.zeros = '.'
        self.interlaced = False
        self.add_extra_zeros = False

    def __str__(self):
        sprite_i = 0
        out = ""
        width = self.width * 2 if self.interlaced else self.width
        y_loop = self.rows()
        for y_axis in range(0, y_loop):
            bin_str = ""
            hex_str = ""
            int_str = ""
            for _ in range(0, width):
                value = self.sprite[sprite_i]
                bin_value = format(value, '0>8b')
                bin_str += f"{bin_value},"
                hex_str += helper.hex_short(value) + ","
                int_str += f"{value},"
                sprite_i += 1
            bin_str = bin_str[:-1]
            LOG.debug(f"{bin_str.replace('0',self.zeros)}    {hex_str[:-1]}   {int_str[:-1]}")
            out += f"{y_axis:02d} {bin_str.replace('0',self.zeros)}    {hex_str[:-1]}   {int_str[:-1]}\n"
        return out

    def copy_no_sprite(self):
        """
        Copy a sprite to create a new one but dont copy of the image
        :return: new sprite like the original without image
        """
        new_sprite = Sprite()
        new_sprite.width = self.width
        new_sprite.zeros = self.zeros
        new_sprite.interlaced = self.interlaced
        new_sprite.add_extra_zeros = self.add_extra_zeros
        new_sprite.sprite = []
        return new_sprite

    def copy(self):
        """
        Make an exact copy of the sprite
        :return: A copy of the sprite
        """
        new_sprite = self.copy_no_sprite()
        new_sprite.sprite = [self.sprite[x] for x in range(len(self.sprite))]
        return new_sprite

    def add_upper_and_lower_zeros(self):
        """
        Add an additional row top and bottom of the sprite
        :return: new sprite with rows added top and bottom
        """
        new_sprite = self.copy()
        new_sprite.add_extra_zeros = True
        for _ in range(0, self.width):
            new_sprite.sprite = ([0] + new_sprite.sprite)
            new_sprite.sprite.append(0)
        return new_sprite

    def read_dbs(self, dbs, width):
        """
        read in a string and convert it to a sprite
        :param dbs: the DBs from a asm file
        :param width: the width of the sprite
        :return: the sprite with all meta data added
        """
        sprite_str_array = dbs.replace(' ', '').split(',')
        sprite = [int("0x" + (sprite_str_array[x])[1:], 16) for x in range(len(sprite_str_array))]
        self.sprite = sprite
        self.width = width
        self.zeros = '.'
        self.interlaced = False
        self.add_extra_zeros = False

    def write_dbs(self, remove_added_zeros=True):
        """
        Create an output of the sprite to be used for DB output
        :param remove_added_zeros:
        :return: output string
        """
        out = ""
        width = self.width if remove_added_zeros else 0
        if not self.add_extra_zeros: width = 0
        if self.interlaced: width *= 2

        for sprite_i in range(width, len(self.sprite) - width):
            value = self.sprite[sprite_i]
            hex_value = helper.hex_short(value)
            out += f"${hex_value},"
        out = out[:-1]
        return out

    def set(self, x_axis, y_axis, value):
        """
        Set a position in the sprite to a value
        :param x_axis: x position across
        :param y_axis: y position down
        :param value: the new value
        :return: n/a
        """
        sprite_i = self.width * y_axis + x_axis
        if sprite_i == 0: self.sprite = [value] + self.sprite[1:]
        else: self.sprite = self.sprite[:sprite_i] + [value] + self.sprite[sprite_i + 1:]

    def get(self, x_axis, y_axis):
        """
        Get a location inside a sprite
        :param x_axis: x position across
        :param y_axis: y position down
        :return: value
        """
        sprite_i = self.width * y_axis + x_axis
        return self.sprite[sprite_i]

    def sprite_ored(self, sprite2):
        """
        OR two sprites together and form a new sprite
        :param sprite2: Second sprite
        :return: new sprite
        """
        new_sprite = sprite2.copy()
        LOG.debug(f"sprite_ored: rows:{self.rows()}, width:{self.width}")
        for y_axis in range(0, self.rows()):
            for x_axis in range(0, self.width):
                value = new_sprite.get(x_axis, y_axis) | self.get(x_axis, y_axis)
                LOG.debug(f"sprite_ored: x:{x_axis} y:{y_axis} v:{value}")
                new_sprite.set(x_axis, y_axis, value)
        return new_sprite

    def sprite_xored(self, sprite2):
        """
        XOR two sprites together and form a new sprite
        :param sprite2: Second sprite
        :return: new sprite
        """
        new_sprite = sprite2.copy()
        for y_axis in range(0, self.rows()):
            for x_axis in range(0, self.width):
                value = new_sprite.get(x_axis, y_axis) ^ self.get(x_axis, y_axis)
                new_sprite.set(x_axis, y_axis, value)
        return new_sprite

    def shift_left(self):
        """
        Shift a sprite left one bit
        :return: new sprite shifted one bit
        """
        new_sprite = self.copy_no_sprite()
        for y_axis in range(0, self.rows()):
            carry = 0
            row = []
            for x_axis in range(self.width, 0, -1):
                sprite_i = y_axis * 2 + x_axis - 1
                value1 = self.sprite[sprite_i]
                value1 = value1 * 2 + carry
                LOG.debug(sprite_i, self.sprite[sprite_i], x_axis, y_axis, value1, carry)
                if value1 > 255:
                    carry = 1
                    value1 -= 256
                else:
                    carry = 0
                row.append(value1)
            # Append the row in reverse order
            for i in range(len(row), 0, -1):
                new_sprite.sprite.append(row[i - 1])
        return new_sprite

    def shift_right(self):
        """
        Shift a sprite right one bit
        :return: new sprite shifted one bit
        """
        new_sprite = self.copy_no_sprite()
        for y_axis in range(0, self.rows()):
            carry = 0
            for x_axis in range(self.width):
                sprite_i = y_axis * 2 + x_axis
                value1 = self.sprite[sprite_i]
                next_carry = value1 % 2
                value1 = int((value1 - next_carry) / 2) + carry * 128
                LOG.debug(sprite_i, self.sprite[sprite_i], x_axis, y_axis, value1, carry)
                carry = next_carry
                new_sprite.sprite.append(value1)
        return new_sprite

    def shift_up(self):
        """
        Shift a sprite up one bit
        :return: new sprite shifted one bit
        """
        new_sprite = self.copy()
        new_sprite.sprite = new_sprite.sprite[new_sprite.width:] + new_sprite.sprite[:new_sprite.width]
        return new_sprite

    def shift_down(self):
        """
        Shift a sprite down one bit
        :return: new sprite shifted one bit
        """
        new_sprite = self.copy()
        new_sprite.sprite = new_sprite.sprite[-new_sprite.width:] + new_sprite.sprite[:-new_sprite.width]
        return new_sprite

    def interlace(self, sprite2):
        """
        Interlace two sprites to form one new interlaces sprite
        :param sprite2: second sprite to interlace with
        :return: Interlaced sprite (combined sprite)
        """
        if self.interlaced:
            new_sprite = self.copy()
        else:
            LOG.debug(self)
            LOG.debug(sprite2)
            new_sprite = self.copy_no_sprite()
            for sprite_i in range(len(self.sprite)):
                new_sprite.sprite.append(sprite2.sprite[sprite_i])
                new_sprite.sprite.append(self.sprite[sprite_i])
            new_sprite.interlaced = True
        return new_sprite

    def rows(self):
        """
        Count the number of rows
        :return: row count
        """
        if self.interlaced: return int(len(self.sprite) / (self.width * 2))
        return int(len(self.sprite) / self.width)

    def create_interlace_sprite(self):
        """
        Create an interlaced sprite from this sprite
        :return: The interlaced sprite
        """
        sprite2 = self.add_upper_and_lower_zeros()
        sprite_and = sprite2.copy()

        sprite_up = sprite2.shift_up()
        sprite_down = sprite2.shift_down()
        sprite_left = sprite2.shift_left()
        sprite_right = sprite2.shift_right()

        LOG.debug("up")
        LOG.debug(sprite_up)
        LOG.debug("down")
        LOG.debug(sprite_down)
        LOG.debug("left")
        LOG.debug(sprite_left)
        LOG.debug("right")
        LOG.debug(sprite_right)

        # print(f"0\n{sprite_and}")
        # print(sprite_up)
        sprite_and = sprite_and.sprite_ored(sprite_up)
        # print(f"01\n{sprite_and}")
        sprite_and = sprite_and.sprite_ored(sprite_down)
        # print(f"02\n{sprite_and}")
        sprite_and = sprite_and.sprite_ored(sprite_left)
        # print(f"03\n{sprite_and}")
        sprite_and = sprite_and.sprite_ored(sprite_right)
        # print(f"1\n{sprite_and}")
        sprite_ff = sprite2.copy_no_sprite()
        sprite_ff.sprite = [255 for x in range(0, sprite2.width * sprite2.rows())]
        # print(f"2\n{sprite_and}")
        sprite_and = sprite_and.sprite_xored(sprite_ff)
        # print(f"3\n{sprite_and}")

        interlace_sprite = sprite2.interlace(sprite_and)
        # print(f"int\n{interlace_sprite}")
        return interlace_sprite


def run():
    """
    Run a sample to show this it works
    :return: n/a
    """
    sprite_x7_y0 = "$00, $60, $00, $7c, $00, $3e, $00, $2c, $00, $7c, $00, $3c, $00, $18, $00, $3c," \
                   "$00, $7e, $00, $7e, $00, $ef, $00, $df, $00, $3c, $00, $6e, $00, $76, $00, $ee"
    sprite_str = sprite_x7_y0
    sprite = Sprite()
    width = 2
    sprite.read_dbs(sprite_str, width)

    print("Original")
    print(sprite)
    print()

    interlace_sprite = sprite.create_interlace_sprite()
    print("Interlaced")
    print(interlace_sprite)
    print()

    dbs = interlace_sprite.write_dbs()
    print(dbs)


if __name__ == "__main__":
    run()
