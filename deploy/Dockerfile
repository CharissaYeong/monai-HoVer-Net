# =====================================================================
# Stage 1: Build Dependencies & Cache Model Bundle
# =====================================================================
FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-runtime AS builder
WORKDIR /app

# Install native compilation dependencies cleanly
RUN apt-get update && apt-get install -y --no-install-recommends \
    libopenslide0 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Install dependencies into a dedicated installation prefix folder
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Download the streamlined NuClick model bundle instead of the heavy HoVer-Net stack
RUN python -m monai.bundle download \
    --name "pathology_nuclick_annotation" \
    --version "0.2.1" \
    --bundle_dir "/app/bundle"

# =====================================================================
# Stage 2: Lean Runtime Layer
# =====================================================================
FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-runtime AS runner
WORKDIR /app

# Install system runtime dependency requirements for digital pathology processing
RUN apt-get update && apt-get install -y --no-install-recommends \
    libopenslide0 \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copy python dependencies and model assets cleanly from builder layer
COPY --from=builder /install /usr/local
COPY --from=builder /app/bundle /app/bundle
COPY src/ /app/src/

# Establish application pathways
ENV PYTHONPATH=/app/src
ENTRYPOINT ["python", "/app/src/pipeline.py"]