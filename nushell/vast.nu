# oof

export def main [] { echo "corn waffle" }


export def "vast api-call get" [
  path: string # The path to make the API call to
  query?: record # The data to scream at the server with
] {
  # Assemble the URL to query
  mut url_record = {
    scheme: "https"
    host: "console.vast.ai"
    path: $"/api/v0/($path)/"
  }
  # Add the specified query, if specified
  if $query != null { $url_record.query = ({ q: ($query | to json --raw)} | url build-query) }
  return (http get --headers ['Authorization' $'Bearer (vast get-api-key)'] ($url_record | url join))
}

export def "vast api-call put" [
  path: string
  data: record
] {
  # Assemble the URL to query
  let url_record = {
    scheme: "https"
    host: "console.vast.ai"
    path: $"/api/v0/($path)/"
  }
  return (http put --headers ['Authorization' $'Bearer (vast get-api-key)'] --content-type application/json ($url_record | url join) ($data | to json --raw))
}


# Retrieve the API key from the usual location
def "vast get-api-key" [] {
  return (open ~/.vast_api_key | into string)
}

# Search for instance types using custom query
export def "vast search offers" [] {
  # Default parameters per vast client
  mut params = {
    verified: { eq: true }
    external: { eq: false }
    rentable: { eq: true }
    rented: { eq: false }
    order: [['score' 'desc']]
    type: 'on-demand'
    allocated_storage: 5.0
  }
  # Custom desired default parameters that we're tacking on
  $params.duration = { gte: 86400.0 }
  $params.datacenter = { eq: true }
  $params.inet_up_cost = { lte: 0.01 }
  $params.inet_down_cost = { lte: 0.01 }
  $params.num_gpus = { eq: 1 }
  $params.gpu_ram = { gte: 8000.0 }
  $params.cpu_cores_effective = { gte: 4 }
  $params.cpu_ram = { gte: 8000.0 }
  $params.inet_down = { gte: '400' }
  $params.cuda_max_good = { gte: '12.1' }
  $params.cpu_arch = { eq: 'amd64' }
  $params.order = [['dph_total' 'asc']]
  $params.allocated_storage = 100.0
  return (
    # vastai search offers --raw --storage 100.0 -o 'dph_total+' $'duration >= 1  datacenter = true  verified = true  rentable = true  inet_up_cost <= 0.01  inet_down_cost <= 0.01  num_gpus = 1  gpu_ram >= ($mem)  cpu_cores_effective >= 4  cpu_ram >= 8  inet_down >= 400  cuda_max_good >= 12.1  cpu_arch = amd64'
    (vast api-call get bundles $params).offers |
      update gpu_ram { |f| $f.gpu_ram * 1024 * 1024 | into filesize } |
      update cpu_ram { |f| $f.cpu_ram * 1024 * 1024 | into filesize } |
      select id    gpu_name gpu_ram total_flops cpu_cores_effective cpu_ghz cpu_ram cuda_max_good geolocation dph_total inet_down inet_up |
      rename index GPU      VRAM    FLOPS       Cores               GHz     RAM     CUDA          Location    Cost      DL        UL
  )
}
export alias vso = vast search offers

export def "vast search offers completion" [] {
  let data = (vast search offers)
  let headers = ['GPU' 'VRAM']
  mut fdata = ($data | select index | rename value)
  mut legend = $'(ansi white_bold)'
  mut headerlen = {}
  for x in ($data | columns) {
    if $x == 'index' { continue }
    print $'ok ($data | get $x | each { |it| str length $it } | max)'
  }
  return $headerlen
}

#return ($data | select index GPU | rename value description | prepend { value: 'ID', description: $'(ansi white_bold)GPU'})
#}

export def "vast show instance" [
  id: int # The instance ID being requested
  --nice # Clean up the output for human readability
] {
  let data = ((vast api-call get $'instances/($id)').instances | rename --column {id: index})
  return $data
}

export alias vsii = vast show instance

export def "vast show instances" [
  --nice # Clean up the output for human readability
] {
  let data = ((vast api-call get instances).instances | rename --column {id: index})
  if $nice {
    return ($data
      | select index machine_id actual_status num_gpus gpu_name gpu_util cpu_cores_effective cpu_ram disk_space ssh_host   ssh_port   dph_total image_uuid inet_up  inet_down  reliability2 label duration
      | rename index Machine    Status        Num      Model    Util%    vCPUs               RAM     Storage    'SSH Addr' 'SSH Port' '$/hr'    Image      'Net up' 'Net Down' R            Label Age ) }
  return ($data | each { |x| sort })
}

export alias vsi = vast show instances


export def "test completion" [] {
  return {
    completions: [
      {value: 'x2 ok' description: "This is option 2" }
      {value: 1 description: "This is option 1" }
      {value: 3 description: "This is option 3" }
    ],
    options: {
      case_sensitive: false
      positional: false
      completion_algorithm: "prefix"
      sort: false
    }
  }
}

export def test [arg: any@"test completion"] { return "ok!" }

def "invokeenv tokens" [] {
  mut output = []
  if "HUGGINGFACE_TOKEN" in $env {
    $output ++= { url_regex: "huggingface.co" token: ($env.HUGGINGFACE_TOKEN) } }
  if "CIVITAI_TOKEN" in $env {
    $output ++= { url_regex: "civitai.com" token: ($env.CIVITAI_TOKEN) } }
  return ($output | to json --raw)
}

export def "invokeenv huggingface" [address: string] {
  let inaddr = ($address | url parse)
  let url_template = {
    scheme: $inaddr.scheme
    host: $inaddr.host
    path: '/api/v2/models/hf_login'
    port: $inaddr.port
  }
  http post ($url_template | url join) ({ token: $env.HUGGINGFACE_TOKEN } | to json --raw)
}

export def "invokeenv models" [address: string models: list<any>] {
  let inaddr = ($address | url parse)
  let url_template = {
    scheme: $inaddr.scheme
    host: $inaddr.host
    path: '/api/v2/models/install'
    port: $inaddr.port
    query: ''
  }
  for model in $models {
    (http post 
      ($url_template | update query ($model | select source inplace | update inplace { |x| into string} | url build-query) | url join)
      ($model | reject source inplace | to json --raw))
  }
}

export const invoke_models = [
  { name: 'WAI-ANI-NSFW-PONYXL v9.0'
    description: 'Pony Diffusion v6 trained on additional NSFW materials.'
    source: 'https://civitai.com/api/download/models/931577?type=Model&format=SafeTensor&size=pruned&fp=fp16'
    base: 'sdxl' type: 'main' format: 'checkpoint' inplace: false
    default_settings: { cfg_scale: 7 height: 1024 scheduler: 'dpmpp_2m_k' steps: 30 width: 1024 } }
  { name: 'Age (-5 to 5)'
    description: 'v1.0, for PonyXL, https://civitai.com/models/402667'
    source: 'https://civitai.com/api/download/models/448977?type=Model&format=SafeTensor'
    base: 'sdxl' type: 'lora' format: 'lycoris' inplace: false }
  { name: 'Breast Size (0 to 5)'
    description: 'v0.8, for PonyXL, https://civitai.com/models/549006'
    source: 'https://civitai.com/api/download/models/610780?type=Model&format=SafeTensor'
    base: 'sdxl' type: 'lora' format: 'lycoris' inplace: false }
  { name: 'Darker Images'
    description: 'v1.9, for PonyXL, https://civitai.com/models/883616'
    source: 'https://civitai.com/api/download/models/989098?type=Model&format=SafeTensor'
    base: 'sdxl' type: 'lora' format: 'lycoris' inplace: false
    trigger_phrases: ['dark theme' 'dim lighting' 'black theme' 'silhouette' 'dark background' 'dark room' 'black background' 'backlighting'] }
  { name: 'Hard Edge Detection (canny)'
    description: 'Uses detected edges in the image to control composition.'
    source: 'xinsir/controlNet-canny-sdxl-1.0'
    base: 'sdxl' type: 'controlnet' format: 'diffusers' inplace: true }
  { name: 'Tile'
    description: 'Uses image data to replicate exact colors/structure in the resulting generation.'
    source: 'xinsir/controlNet-tile-sdxl-1.0'
    base: 'sdxl' type: 'controlnet' format: 'diffusers' inplace: true }
  { name: 'Standard Reference (IP Adapter ViT-H)'
    description: 'References images with a higher degree of precision.'
    source: 'https://huggingface.co/InvokeAI/ip_adapter_sdxl_vit_h/resolve/main/ip-adapter_sdxl_vit-h.safetensors'
    base: 'sdxl' type: 'ip_adapter' format: 'checkpoint' inplace: true }
  { name: 'IP Adapter SDXL Image Encoder'
    description: 'IP Adapter SDXL Image Encoder'
    source: 'InvokeAI/ip_adapter_sdxl_image_encoder'
    base: 'sdxl' type: 'clip_vision' format: 'diffusers' inplace: true }
  { name: 'RealESRGAN_x2plus'
    description: 'A Real-ESRGAN 2x upscaling model (general-purpose).'
    source: 'https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.1/RealESRGAN_x2plus.pth'
    base: 'any' type: 'spandrel_image_to_image' format: null inplace: true }
  { name: 'RealESRGAN_x4plus_anime_6B'
    description: 'A Real-ESRGAN 4x upscaling model (optimized for anime images).'
    source: 'https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.2.4/RealESRGAN_x4plus_anime_6B.pth'
    base: 'any' type: 'spandrel_image_to_image' format: null inplace: true }
]

export def "vast run" [] {}
export def "vast run invokeai" [offer: int@"test completion", --vram: int] {
  # Ensure that port 9090 isn't in use before we start
  if (port 9090) != 9090 { error make -u { msg: "Port 9090 is currently in use." } }
  #vastai create instance --explain --raw 13416877 --image ghcr.io/invoke-ai/invokeai --disk 100 --ssh --cancel-unavail --direct --onstart-cmd invokeai-web --env '-e INVOKEAI_RANDOM=25'
  mut $req = {
    client_id: 'me'
    image: 'ghcr.io/invoke-ai/invokeai'
    env: {
      INVOKEAI_REMOTE_API_TOKENS: (invokeenv tokens)
      INVOKEAI_LAZY_OFFLOAD: 'true' }
    price: null
    disk: 100.0
    label: null
    extra: null
    onstart: 'touch ~/.no_auto_tmux; invokeai-web'
    image_login: null
    python_utf8: false
    lang_utf8: false
    jupyter_dir: none
    force: false
    cancel_unavail: true
    template_hash_id: null
    runtype: 'ssh_direc ssh_proxy'
  }
  if $vram != null { $req.env.INVOKEAI_RAM = ($vram | into string) }
  # Create the actual vast.ai instance
  let instance_creation = (vast api-call put $'asks/($offer)' $req)
  if $instance_creation.success != true { error make -u { msg: "Instance creation failed." } }
  # Store our instance ID so that we can use it easily
  let iid = $instance_creation.new_contract
  print $'Instance created: ($iid)'
  # Loop until the docker container has reached the "running" state
  mut status = {actual_status: ''}
  while $status.actual_status != 'running' {
    sleep 5sec
    $status = (vast show instance $iid)
    print $'($status.actual_status): ($status.status_msg | str trim)'
  }
  print 'Waiting for tunnel...'
  cmd /c $'start ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL -o PasswordAuthentication=no -fN -L9090:localhost:9090 (vastai ssh-url ($iid))'
  sleep 5sec
  try { let sshpid = ((ps -l | where command =~ '-L9090:localhost:9090').0.pid) } catch { error make -u { msg: "SSH process has died." } }
  print 'Waiting for InvokeAI...'
  mut invoke_ready = false
  while $invoke_ready == false {
    try {
      http get 'http://localhost:9090'
      $invoke_ready = true
    } catch { sleep 1sec }
  }
  invokeenv huggingface 'http://localhost:9090'
  invokeenv models 'http://localhost:9090' $invoke_models
  print 'Ready! http://localhost:9090'
}
