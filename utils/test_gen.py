#! /usr/bin/env python3
from argparse import ArgumentParser
from random import randint
from pathlib import Path


class Convoluter():
    def __init__(self):
        self.state = 0

    def get_bit(self, i):
        if self.state == 0:
            if i == 0:
                self.state = 0
                return 0
            self.state = 2
            return 3
        if self.state == 1:
            if i == 0:
                self.state = 0
                return 3
            self.state = 2
            return 0
        if self.state == 2:
            if i == 0:
                self.state = 1
                return 1
            self.state = 3
            return 2
        if self.state == 3:
            if i == 0:
                self.state = 1
                return 2
            self.state = 3
            return 1
        raise ValueError("Invalid state")


def solve(_input):
    conv = Convoluter()
    out = []

    for byte in _input:
        out_byte = 0
        for j in range(0, 8):
            bit = 1 & (byte >> 7 - j)
            result = conv.get_bit(bit)
            out_byte = out_byte | (result << (2 * (7 - j)))
        out.append(out_byte >> 8)
        out.append(out_byte & 255)

    return out


def gen_test(max_test_size):
    out = []

    size = randint(0, max_test_size)
    _input = [randint(0, 255) for _ in range(0, size)]
    _output = solve(_input)

    out.append(size)
    out = out + _input + _output
    return out


def translate_test(test, n):
    return \
        f"Test {n}:\n" + \
        f"  size: {test[0]}\n" + \
        f"  input: {' '.join([str(i) for i in test[1:test[0] + 1]])}\n" + \
        f"  expected output: {' '.join([str(i) for i in test[test[0] + 1:]])}\n"


def porcelain_test(test):
    return '\n'.join([str(i) for i in test]) + '\n'


def gen_output(out, n_test, max_test_size):
    out_porcelain = Path(out, 'ram_contents')
    out_human = Path(out, 'test_contents')
    with open(out_porcelain, 'wt') as porcelain:
        with open(out_human, 'wt') as human:
            for i in range(0, n_test):
                test = gen_test(max_test_size)
                human.write(translate_test(test, i))
                porcelain.write(porcelain_test(test))


def main():
    parser = ArgumentParser(description='''
            Generate a file loadable by the VHDL testbench containing a specified
            number of tests of random size. Defaults are 5 tests with maximum
            255 words of input.''',
                            epilog='''
            The program outputs two files: ram_contents and test_contents.

            The first is a series of integers representing ram content.
            They are oredered as such: size, input (`size` integers), output
            (2x`size` integers). This file should be fed into the automated VHDL
            testbench.

            The second is a human readable description of the generated machine
            readable file.

            There is no separation between different test cases.
        ''')
    parser.add_argument('-n', default=5, type=int, help="Number of tests")
    parser.add_argument('-s',
                        default=255,
                        type=int,
                        help="Maximum input stream size")
    parser.add_argument('-o', default='./', type=str, help="Output folder")
    args = parser.parse_args()
    gen_output(args.o, args.n, args.s)


if __name__ == '__main__':
    main()
