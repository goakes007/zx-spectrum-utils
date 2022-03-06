"""
Image processing module
"""
import pygame
import helper
LOG = helper.log_from_file_path(__file__)

# Define the colours we will use in RGB format
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
BLUE = (0, 0, 255) 
GREEN = (0, 150, 0)
LGREEN = (0, 255, 0)
RED = (255, 0, 0)


def draw_text(screen, colour, point, text, size=15):
    """
    Add text to the surface of the screen
    :param screen: screen to blitz
    :param colour: colour
    :param point: location
    :param text: text
    :param size: size
    :return: n/a
    """
    LOG.debug(f"draw_text: screen:{screen}, colour:{colour}, point:{point}, text:{text}, size:{size}")
    font = pygame.font.SysFont('Ariel', size)
    text_surface = font.render(text, True, colour)
    text_rect = text_surface.get_rect()
    text_rect.topleft = point
    screen.blit(text_surface, text_rect)


def get_byte_image(byte_value, size=1):
    """
    Get a image that represents the byte value passed
    :param byte_value: byte value needed
    :param size: resize as necessary
    :return: image
    """
    image = mapping_image.subsurface((0, byte_value, 8, 1))
    if size != 1:
        image = pygame.transform.scale(image, (8 * size, 1 * size))
    return image


def show_graphics(screen, snap_memory, mem_ptr, width, rows, scn_x, scn_y, size=2):
    """
    Add a graphic to the screen
    :param screen: screen to blitz
    :param snap_memory: spectrum memory
    :param mem_ptr: pointer in memory
    :param width: width of image
    :param rows: heigh of image
    :param scn_x: screen x location
    :param scn_y: screen y location
    :param size: resize as needed
    :return: n/a
    """
    for j in range(0, rows):
        for k in range(0, width):
            if mem_ptr < len(snap_memory):
                peek = snap_memory[mem_ptr]
                byte_image = get_byte_image(peek, size=size)
                screen.blit(byte_image, (scn_x + k * 16 * size / 2, scn_y + (j * size)))
            mem_ptr += 1


def create_image_mapper():
    """
    Create images to represent binary 0 to 255 for faster drawing
    :return: the mapping image
    """
    image = pygame.Surface((8, 256))
    image.fill(WHITE)
    for i in range(0, 256):
        bit_monitor = i
        bit_index = 7
        while bit_monitor > 0:
            if bit_monitor % 2: image.set_at((bit_index, i), BLACK)
            else: image.set_at((bit_index, i), WHITE)
            bit_monitor = int(bit_monitor / 2)
            bit_index -= 1
    return image


mapping_image = create_image_mapper()
