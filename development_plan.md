# Development plan

## Byte interface
Buffers a FIFO of pixels

### Input
* Pixel input
* Ready signal when new pixel is accepted
* Valid signal when valid pixel is on data-line

### Output
* Pixel output
* Ready master
* Valid master

## Color serializer
Buffers a pixel to make sure that it is held steady during transmission

### Input
* Pixel color. `24bGRB`
* Ready slave
* Valid slave

### Output
* Bit by bit output
* Ready master
* Valid master

### State machine
#### Idle
Waiting for a pixel to be sent
#### Send G, R, B
Send either pixel value at a time, **MSb** ***first***. Use either `T1H`, `T1L` or `T0H`, `T0L` as the periods.

## Bit serialisation
Default voltage level: `0V`. Active voltage level: `~VDD` (`+6-7V`)

### Input
* Bit by bit input
* Ready slave. Low when sending reset or when sending a pixel.
* Valid slave

### Output
* Bit serialization output
  * **GRB** order, **MSb** (high bit) ***first***
* Error bit

### State machine
#### Reset
At start, or after reset, the line must be held low for at least `RES` us. Transition to bit high when
#### Bit high
Use the high time for either 1 or 0 depending on the input value
#### Bit low
Upon error, go into reset state
#### Error
When some timing error has occured. Must set error flag high.

### Timing information
[Original timing information](https://cdn-shop.adafruit.com/datasheets/WS2812.pdf)

#### Empirical timing diagram
| Type   | Time `+- 0.15` [us] |
|--------|---------------------|
| `T0H`  | `0.35`              |
| `T0L`  | `0.80`              |
| `T1H`  | `0.70`              |
| `T1L`  | `0.60`              |
| `RES`  | `5.00` minimum      |
Total period time: `TH + TL = 1250ns (+- 600ns)`

#### Simplified timing diagram
Taken from [Josh.com](https://wp.josh.com/2014/05/13/ws2812-neopixels-are-not-so-finicky-once-you-get-to-know-them/).

| Symbol |  Parameter                | Min     | Typical   | Max    | Units |
|--------|---------------------------|---------|-----------|--------|-------|
| `T0H`  | 0 code, high voltage time | `200`   | `350`     | `500`  |   ns  |
| `T1H`  | 1 code, high voltage time | `550`   | `700`     |        |   ns  |
| `TLD`  | data, low voltage time    | `450`   | `600`     | `5000` |   ns  |
| `TLL`  | latch, low voltage time   | `6000`  |           |        |   ns  |
