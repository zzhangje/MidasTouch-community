# MidasTouch Community

MidasTouch performs online global localization of a vision-based touch sensor on an object surface during sliding interactions using Monte-Carlo inference over distributions. For more details, see the authors' <a href="https://suddhu.github.io/midastouch-tactile/">website</a> or their <a href="https://openreview.net/forum?id=JWROnOf4w-K">paper</a>.

This is a patched version compatible with **Python 3.8 to 3.11** (`open3d` does not support Python 3.13, `distutils` does not support Python 3.12 or above). A `Dockerfile` is provided to minimize setup time, including pre-installed dependencies such as MinkowskiEngine.

<div align="center">
  <img src=".github/power_drill_ycb_slide.png"
  width="35%"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <img src=".github/power_drill_train_data.png"
  width="35%">
</div>

## Setup

Build the docker image and allows docker to connect to your X server. You can specify the Ubuntu, CUDA, PyTorch version via [Dockerfile](./Dockerfile).

> [Minkowski Engine](https://github.com/NVIDIA/MinkowskiEngine) is compatible with `numpy<=1.23.0` and `CUDA 10.2` or `CUDA 11.X`. The install option is set to `cpu_only` by default due to incompatibility with `CUDA 11.3` on the `RTX 4060`. You can change this to `force_cuda` if you prefer GPU support.

```bash
docker build -t midastouch .
xhost +local:root
```

Enter docker container via terminal and install `midastouch`.

```bash
docker run --gpus all \
  -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $(pwd):/workspace/midastouch \
  midastouch bash

cd /workspace/midastouch
pip install -e .
```

Download the weights, codebooks, and dataset. `gdown` is required for the following command.

```bash
# download weights/codebooks
chmod +x download_assets.sh && ./download_assets.sh

# download YCB-Slide dataset
git submodule update --init --recursive
cd YCB-Slide && chmod +x download_dataset.sh && ./download_dataset.sh && cd ..
```

## Usage

- [x] `data_gen/generate_data.py`

  ```bash
  python data_gen/generate_data.py
  ```

- [x] `filter/filter.py`
  ```bash
  python midastouch/filter/filter.py expt=ycb # default: 004_sugar_box log 0
  python midastouch/filter/filter.py expt.obj_model=035_power_drill expt.log_id=3 # 035_power_drill log 3
  python midastouch/filter/filter.py expt.off_screen=True   # disable visualization
  python midastouch/filter/filter.py expt=mcmaster   # small parts: cotter-pin log 0
  ```

- [x] `filter/filter_real.py`

  ```bash
  python midastouch/filter/filter_real.py expt=ycb # default: 004_sugar_box log 0
  python midastouch/filter/filter_real.py expt.obj_model=021_bleach_cleanser expt.log_id=2 # 021_bleach_cleanser log 2
  ```

## License

The majority of MidasTouch is licensed under MIT license, however portions of the project are available under separate license terms: MinkLoc3D is licensed under the MIT license; FCRN-DepthPrediction is licensed under the BSD 2-clause license; pytorch3d is licensed under the BSD 3-clause license. Please see the [LICENSE](LICENSE) file for more information.
