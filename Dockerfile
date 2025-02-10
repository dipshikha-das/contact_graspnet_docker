# Use an official Python base image
FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu20.04 AS base
# Install dependencies for installing Conda
RUN apt-get update && apt-get install -y \
    wget \
    bzip2 \
    curl \
    build-essential \
    g++ \
    vim \
    ca-certificates \
    libgl1-mesa-glx \
    libglu1-mesa \
    libx11-dev \
    libxkbcommon-x11-0 \
    libxcb-xinerama0 \
    libxcomposite1 \
    libxrandr2 \
    libxt6


# Download and install Miniconda (small version of Anaconda)
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh

# Add Conda to PATH
ENV PATH=/opt/conda/bin:$PATH

COPY qt_deps.sh /qt_deps.sh
RUN chmod +x /qt_deps.sh
RUN /qt_deps.sh

# Create a directory for the app
WORKDIR /contact_graspnet

FROM base AS final

COPY compile_pointnet_tfops.sh .

# Copy the environment.yml (you will create this later)
COPY contact_graspnet_env.yml /
RUN chmod +x compile_pointnet_tfops.sh

# Create the Conda environment from the environment.yml file
RUN conda env create -f /contact_graspnet_env.yml

# Activate the environment by default (optional)
SHELL ["conda", "run", "-n", "contact_graspnet_env", "/bin/bash", "-c"]

# Set up ROS environment
RUN echo "source /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate contact_graspnet_env" >> ~/.bashrc && \
    echo "export HOME=/contact_graspnet" >> ~/.bashrc && \
    echo "export XDG_RUNTIME_DIR=/tmp/runtime-root" >> ~/.bashrc && \
    echo "export QT_QPA_PLATFORM_PLUGIN_PATH=/opt/conda/envs/contact_graspnet_env/lib/python3.7/site-packages/cv2/qt/plugins" >> ~/.bashrc

# Activate the Conda environment and ensure ROS is sourced
CMD ["bash", "-c", "source /opt/conda/etc/profile.d/conda.sh && conda activate contact_graspnet_env && bash"]
