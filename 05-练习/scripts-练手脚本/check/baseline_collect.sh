#!/usr/bin/env bash
set -euo pipefail

OUT_DIR=""
USER_BOM_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bom)
      USER_BOM_PATH="${2:-}"
      shift 2
      ;;
    --out)
      OUT_DIR="${2:-}"
      shift 2
      ;;
    *)
      if [[ -z "${OUT_DIR}" ]]; then
        OUT_DIR="$1"
      fi
      shift
      ;;
  esac
done

OUT_DIR="${OUT_DIR:-baseline-collect-$(date +%F-%H%M%S)}"
RAW_DIR="${OUT_DIR}/raw"
RUN_LOG="${OUT_DIR}/run.log"
mkdir -p "${RAW_DIR}"

log() {
  local level="$1"
  shift
  printf '[%s] %s\n' "${level}" "$*" | tee -a "${RUN_LOG}"
}

on_error() {
  local exit_code="$?"
  local line_no="${1:-unknown}"
  log "ERROR" "script failed at line ${line_no}, exit_code=${exit_code}"
  exit "${exit_code}"
}

trap 'on_error ${LINENO}' ERR

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

run_capture() {
  local name="$1"
  shift
  local out="${RAW_DIR}/${name}.txt"
  {
    echo "# COMMAND: $*"
    echo "# TIME: $(date '+%F %T')"
    echo
    "$@"
  } >"${out}" 2>&1 || true
}

run_capture_sh() {
  local name="$1"
  local cmd="$2"
  local out="${RAW_DIR}/${name}.txt"
  {
    echo "# COMMAND: ${cmd}"
    echo "# TIME: $(date '+%F %T')"
    echo
    bash -lc "${cmd}"
  } >"${out}" 2>&1 || true
}

redfish_get() {
  local name="$1"
  local path="$2"
  run_capture_sh "${name}" "curl -ksu '${RF_USER}:${RF_PASS}' 'https://${RF_HOST}${path}'"
}

first_data_line() {
  local file="$1"
  if [[ -f "${file}" ]]; then
    awk 'NF>0 && $0 !~ /^# (COMMAND|TIME):/ {print; exit}' "${file}" | tr -d '\r'
  else
    echo "N/A"
  fi
}

strip_capture_header() {
  local file="$1"
  awk 'BEGIN{skip=1} {
    if (skip && ($0 ~ /^# (COMMAND|TIME):/ || $0 ~ /^[[:space:]]*$/)) next
    skip=0
    print
  }' "${file}"
}

value_by_key() {
  local file="$1"
  local key_regex="$2"
  if [[ -f "${file}" ]]; then
    awk -F: -v pat="${key_regex}" '
      $0 ~ pat {
        v=$0
        sub(/^[^:]*:[[:space:]]*/, "", v)
        print v
        exit
      }
    ' "${file}" | xargs
  fi
}

json_value_by_key() {
  local file="$1"
  local key="$2"
  if [[ -f "${file}" ]]; then
    strip_capture_header "${file}" | tr -d '\r\n' | sed -n "s/.*\"${key}\":[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n1
  fi
}

firmware_value() {
  local id="$1"
  local key="$2"
  local file="${RAW_DIR}/redfish_fw_${id}.txt"
  if [[ -f "${file}" ]]; then
    json_value_by_key "${file}" "${key}"
  fi
}

pick_os_name() {
  if [[ -f /etc/os-release ]]; then
    awk -F= '/^PRETTY_NAME=/{gsub(/"/,"",$2);print $2}' /etc/os-release
  else
    uname -o 2>/dev/null || echo "Unknown"
  fi
}

markdown_table_to_html() {
  local md_file="$1"
  local title="$2"
  local out_file="$3"
  {
    echo '<!DOCTYPE html>'
    echo '<html lang="zh-CN">'
    echo '<head>'
    echo '  <meta charset="UTF-8">'
    echo "  <title>${title}</title>"
    echo '  <style>'
    echo '    body { font-family: "Microsoft YaHei", "PingFang SC", Arial, sans-serif; margin: 12px; color: #333; background: #fff; }'
    echo '    h1 { font-size: 18px; margin: 0 0 12px; }'
    echo '    table { border-collapse: collapse; width: 100%; table-layout: auto; }'
    echo '    th, td { border: 1px solid #cfd6df; padding: 8px 10px; font-size: 14px; vertical-align: top; word-break: break-word; }'
    echo '    th { background: #eef2f6; font-weight: 700; text-align: left; }'
    echo '    tr:nth-child(even) td { background: #fafbfd; }'
    echo '    .wrap { max-width: 1600px; }'
    echo '  </style>'
    echo '</head>'
    echo '<body>'
    echo '  <div class="wrap">'
    echo "    <h1>${title}</h1>"
    awk '
      function esc(s) {
        gsub(/&/, "\\&amp;", s)
        gsub(/</, "\\&lt;", s)
        gsub(/>/, "\\&gt;", s)
        return s
      }
      BEGIN { row=0; print "    <table>" }
      /^\|/ {
        line=$0
        gsub(/\r/, "", line)
        if (line ~ /^\|---/) next
        sub(/^\|/, "", line)
        sub(/\|$/, "", line)
        n=split(line, a, /\|/)
        row++
        if (row == 1) {
          print "      <thead><tr>"
          for (i=1; i<=n; i++) {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", a[i])
            printf "        <th>%s</th>\n", esc(a[i])
          }
          print "      </tr></thead>"
          print "      <tbody>"
        } else {
          print "      <tr>"
          for (i=1; i<=n; i++) {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", a[i])
            printf "        <td>%s</td>\n", esc(a[i])
          }
          print "      </tr>"
        }
      }
      END {
        if (row >= 1) print "      </tbody>"
        print "    </table>"
      }
    ' "${md_file}"
    echo '  </div>'
    echo '</body>'
    echo '</html>'
  } > "${out_file}"
}

parse_bom_to_tsv() {
  local bom_path="$1"
  local out_tsv="$2"
  case "${bom_path##*.}" in
    csv|CSV)
      python3 - "$bom_path" "$out_tsv" <<'PY'
import csv, sys
src, dst = sys.argv[1], sys.argv[2]
with open(src, 'r', encoding='utf-8-sig', newline='') as f:
    rows = list(csv.reader(f))
with open(dst, 'w', encoding='utf-8') as out:
    for row in rows:
        out.write("\t".join((cell or "").replace("\t"," ").replace("\n"," ") for cell in row) + "\n")
PY
      ;;
    xlsx|XLSX)
      python3 - "$bom_path" "$out_tsv" <<'PY'
import re, sys, zipfile
import xml.etree.ElementTree as ET
src, dst = sys.argv[1], sys.argv[2]
ns = {'x': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main',
      'r': 'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
      'pr': 'http://schemas.openxmlformats.org/package/2006/relationships'}
def col_idx(cell_ref):
    letters = re.match(r'([A-Z]+)', cell_ref).group(1)
    n = 0
    for ch in letters:
        n = n * 26 + (ord(ch) - 64)
    return n - 1
with zipfile.ZipFile(src) as zf:
    shared = []
    if 'xl/sharedStrings.xml' in zf.namelist():
        root = ET.fromstring(zf.read('xl/sharedStrings.xml'))
        for si in root.findall('.//x:si', ns):
            texts = [t.text or '' for t in si.findall('.//x:t', ns)]
            shared.append(''.join(texts))
    wb = ET.fromstring(zf.read('xl/workbook.xml'))
    rels = ET.fromstring(zf.read('xl/_rels/workbook.xml.rels'))
    rel_map = {rel.attrib['Id']: rel.attrib['Target'] for rel in rels.findall('.//pr:Relationship', ns)}
    target_sheet = None
    for sheet in wb.findall('.//x:sheets/x:sheet', ns):
        name = sheet.attrib.get('name', '')
        rid = sheet.attrib.get('{%s}id' % ns['r'])
        if name == '样机BOM':
            target_sheet = 'xl/' + rel_map[rid]
            break
    if target_sheet is None:
        sheets = wb.findall('.//x:sheets/x:sheet', ns)
        rid = sheets[0].attrib.get('{%s}id' % ns['r'])
        target_sheet = 'xl/' + rel_map[rid]
    root = ET.fromstring(zf.read(target_sheet))
    rows_out = []
    for row in root.findall('.//x:sheetData/x:row', ns):
        cells = []
        for c in row.findall('x:c', ns):
            idx = col_idx(c.attrib['r'])
            while len(cells) <= idx:
                cells.append('')
            t = c.attrib.get('t')
            val = ''
            if t == 'inlineStr':
                node = c.find('x:is/x:t', ns)
                val = node.text if node is not None and node.text else ''
            else:
                vnode = c.find('x:v', ns)
                if vnode is not None and vnode.text is not None:
                    val = vnode.text
                    if t == 's':
                        try:
                            val = shared[int(val)]
                        except Exception:
                            pass
            cells[idx] = (val or '').replace('\t', ' ').replace('\n', ' ')
        rows_out.append(cells)
with open(dst, 'w', encoding='utf-8') as out:
    for row in rows_out:
        out.write('\t'.join(row) + '\n')
PY
      ;;
    *)
      return 1
      ;;
  esac
}

log "INFO" "Output directory: ${OUT_DIR}"

BOM_TSV=""
if [[ -n "${USER_BOM_PATH}" ]]; then
  BOM_TSV="${RAW_DIR}/bom.tsv"
  if parse_bom_to_tsv "${USER_BOM_PATH}" "${BOM_TSV}"; then
    log "INFO" "BOM parsed: ${USER_BOM_PATH}"
  else
    log "WARN" "BOM parse failed: ${USER_BOM_PATH}"
    BOM_TSV=""
  fi
fi

log "INFO" "Stage: raw collection"
run_capture uname_a uname -a
run_capture_sh os_release "cat /etc/os-release"
run_capture_sh gcc_version "LC_ALL=C gcc --version | head -n 1"
run_capture_sh lspci "LC_ALL=C lspci"
run_capture_sh lspci_vv "LC_ALL=C lspci -vv"
run_capture_sh lsblk "LC_ALL=C lsblk -d -P -o NAME,MODEL,SERIAL,SIZE,ROTA,TYPE"
run_capture_sh lscpu "LC_ALL=C lscpu"
run_capture_sh meminfo "cat /proc/meminfo"
run_capture_sh dmidecode_bios "LC_ALL=C dmidecode -t bios"
run_capture_sh dmidecode_baseboard "LC_ALL=C dmidecode -t baseboard"
run_capture_sh dmidecode_memory "LC_ALL=C dmidecode -t memory"
run_capture_sh ipmitool_mc_info "LC_ALL=C ipmitool mc info"
run_capture_sh modinfo_nvme "LC_ALL=C modinfo nvme | head -n 30"
if has_cmd nvme; then
  run_capture_sh nvme_list "LC_ALL=C nvme list"
  run_capture_sh nvme_list_json "LC_ALL=C nvme list -o json"
  run_capture_sh nvme_list_subsys "LC_ALL=C nvme list-subsys"
fi
if has_cmd smartctl; then
  run_capture_sh smart_scan "LC_ALL=C smartctl --scan-open"
fi
if [[ -n "${BMC_HOST:-}" && -n "${BMC_USER:-}" && -n "${BMC_PASS:-}" ]]; then
  run_capture_sh ipmitool_mc_info_lanplus "LC_ALL=C ipmitool -I lanplus -H '${BMC_HOST}' -U '${BMC_USER}' -P '${BMC_PASS}' mc info"
fi
if [[ -n "${RF_HOST:-}" && -n "${RF_USER:-}" && -n "${RF_PASS:-}" ]]; then
  redfish_get redfish_root "/redfish/v1/"
  redfish_get redfish_system_1 "/redfish/v1/Systems/1"
  redfish_get redfish_manager_1 "/redfish/v1/Managers/1"
  redfish_get redfish_firmware_inventory "/redfish/v1/UpdateService/FirmwareInventory"
  redfish_next="$(strip_capture_header "${RAW_DIR}/redfish_firmware_inventory.txt" | tr -d '\r\n' | sed -n 's/.*"Members@odata.nextLink":"\([^"]*\)".*/\1/p' | head -n1)"
  if [[ -n "${redfish_next}" ]]; then
    redfish_get redfish_firmware_inventory_page2 "${redfish_next}"
  fi
  firmware_member_paths="$(
    {
      strip_capture_header "${RAW_DIR}/redfish_firmware_inventory.txt"
      [[ -f "${RAW_DIR}/redfish_firmware_inventory_page2.txt" ]] && strip_capture_header "${RAW_DIR}/redfish_firmware_inventory_page2.txt"
    } | grep -o '"/redfish/v1/UpdateService/FirmwareInventory/[^"]*"' | tr -d '"' | sort -u
  )"
  if [[ -n "${firmware_member_paths}" ]]; then
    while IFS= read -r member_path; do
      [[ -z "${member_path}" ]] && continue
      redfish_get "redfish_fw_$(basename "${member_path}")" "${member_path}"
    done <<< "${firmware_member_paths}"
  fi
fi

log "INFO" "Stage: parse fields"
OS_NAME="$(pick_os_name)"
KERNEL_VER="$(uname -r 2>/dev/null || echo N/A)"
GCC_VER="$(first_data_line "${RAW_DIR}/gcc_version.txt")"
BIOS_VER="$(value_by_key "${RAW_DIR}/dmidecode_bios.txt" "^[[:space:]]*Version:[[:space:]]*")"
[[ -z "${BIOS_VER}" ]] && BIOS_VER="$(json_value_by_key "${RAW_DIR}/redfish_system_1.txt" "BiosVersion")"
[[ -z "${BIOS_VER}" ]] && BIOS_VER="N/A"
BMC_VER="$(json_value_by_key "${RAW_DIR}/redfish_manager_1.txt" "FirmwareVersion")"
BMC_SRC_NOTE="from Redfish /Managers/1"
if [[ -z "${BMC_VER}" ]]; then
  BMC_VER="$(value_by_key "${RAW_DIR}/ipmitool_mc_info.txt" "^[[:space:]]*Firmware Revision[[:space:]]*:")"
  BMC_SRC_NOTE="from ipmitool mc info"
fi
[[ -z "${BMC_VER}" ]] && BMC_VER="N/A"
CPU_VENDOR="$(value_by_key "${RAW_DIR}/lscpu.txt" "^Vendor ID:[[:space:]]*")"
CPU_MODEL="$(value_by_key "${RAW_DIR}/lscpu.txt" "^Model name:[[:space:]]*")"
[[ -z "${CPU_MODEL}" ]] && CPU_MODEL="$(value_by_key "${RAW_DIR}/lscpu.txt" "^BIOS Model name:[[:space:]]*")"
[[ -z "${CPU_MODEL}" ]] && CPU_MODEL="$(strip_capture_header "${RAW_DIR}/redfish_system_1.txt" | tr -d '\r\n' | sed -n 's/.*"ProcessorSummary":{[^}]*"Model":"\([^"]*\)".*/\1/p' | head -n1)"
CPU_THREADS="$(value_by_key "${RAW_DIR}/lscpu.txt" "^CPU[(]s[)]:[[:space:]]*")"
CPU_SOCKETS="$(value_by_key "${RAW_DIR}/lscpu.txt" "^Socket[(]s[)]:[[:space:]]*")"
CPU_CORES_PER_SOCKET="$(value_by_key "${RAW_DIR}/lscpu.txt" "^Core[(]s[)] per socket:[[:space:]]*")"
CPU_MAX_MHZ="$(value_by_key "${RAW_DIR}/lscpu.txt" "^CPU max MHz:[[:space:]]*")"
CPU_L3_CACHE="$(value_by_key "${RAW_DIR}/lscpu.txt" "^L3 cache:[[:space:]]*")"
CPU_PHYSICAL_CORES="N/A"
if [[ "${CPU_SOCKETS:-}" =~ ^[0-9]+$ && "${CPU_CORES_PER_SOCKET:-}" =~ ^[0-9]+$ ]]; then
  CPU_PHYSICAL_CORES="$((CPU_SOCKETS * CPU_CORES_PER_SOCKET))"
fi
MEM_TOTAL="$(awk '/MemTotal/{printf "%.1f GiB", $2/1024/1024}' "${RAW_DIR}/meminfo.txt" 2>/dev/null || echo N/A)"
MEM_SPEED="$(value_by_key "${RAW_DIR}/dmidecode_memory.txt" "^[[:space:]]*Speed:[[:space:]]*[0-9]")"
MEM_VENDOR="$(value_by_key "${RAW_DIR}/dmidecode_memory.txt" "^[[:space:]]*Manufacturer:[[:space:]]*")"
DIMM_COUNT="$(grep -c '^[[:space:]]*Size:[[:space:]]*[0-9]' "${RAW_DIR}/dmidecode_memory.txt" 2>/dev/null || true)"
[[ -z "${DIMM_COUNT}" || "${DIMM_COUNT}" == "0" ]] && DIMM_COUNT="N/A"

bom_pick_line() {
  local pattern="$1"
  if [[ -n "${BOM_TSV}" && -f "${BOM_TSV}" ]]; then
    awk -F'\t' -v pat="${pattern}" 'NR>1 { if ($0 ~ pat) { print; exit } }' "${BOM_TSV}"
  fi
}
bom_field() {
  local line="$1"
  local idx="$2"
  if [[ -n "${line}" ]]; then
    printf '%s\n' "${line}" | awk -F'\t' -v i="${idx}" '{print $i}'
  fi
}

sanitize_bom_value() {
  local v="${1:-}"
  v="$(printf '%s' "${v}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
  case "${v}" in
    ""|"新物料"|"N/A"|"n/a"|"-"|"--")
      echo ""
      ;;
    *)
      echo "${v}"
      ;;
  esac
}

CPU_BOM_LINE="$(bom_pick_line '(^|	)(CPU|处理器)($|	)')"
MEM_BOM_LINE="$(bom_pick_line '内存.*64G|D5-5600 64G|内存_64G_D5_5600')"
RAID_BOM_LINE="$(bom_pick_line 'RAID标卡|SP686C-M-16i|SP686C')"
NIC_STD_BOM_LINE=""
NIC_OCP_BOM_LINE=""
MB_BOM_LINE="$(bom_pick_line '主板L6 BB')"
BP_BOM_LINE="$(bom_pick_line '4x3[.]5.*背板|前置背板')"
FRONT_FAN_BOM_LINE="$(bom_pick_line '鍓嶇疆椋庢墖鏉?|FAN-0003')"
MID_FAN_BOM_LINE="$(bom_pick_line '涓疆椋庢墖鏉?|FAN-0002')"
PSU_BOM_LINE=""
NIC_100G_BOM_LINE="$(bom_pick_line '100G.*缃戝崱|SP670|QSFP28')"
NIC_25G_BOM_LINE="$(bom_pick_line 'SF223D-H|25G.*鐏垫椿缃戝崱')"
NIC_10G_BOM_LINE="$(bom_pick_line 'SF221Q|10G.*鐏垫椿缃戝崱|鍥涘彛10G')"

CPU_BOM_PN="$(bom_field "${CPU_BOM_LINE}" 3)"; CPU_BOM_BATCH="$(bom_field "${CPU_BOM_LINE}" 4)"; CPU_BOM_DESC="$(bom_field "${CPU_BOM_LINE}" 5)"
MEM_BOM_PN="$(bom_field "${MEM_BOM_LINE}" 3)"; MEM_BOM_BATCH="$(bom_field "${MEM_BOM_LINE}" 4)"; MEM_BOM_DESC="$(bom_field "${MEM_BOM_LINE}" 5)"
RAID_BOM_PN="$(bom_field "${RAID_BOM_LINE}" 3)"; RAID_BOM_BATCH="$(bom_field "${RAID_BOM_LINE}" 4)"; RAID_BOM_DESC="$(bom_field "${RAID_BOM_LINE}" 5)"
NIC_STD_BOM_PN="$(bom_field "${NIC_STD_BOM_LINE}" 3)"; NIC_STD_BOM_BATCH="$(bom_field "${NIC_STD_BOM_LINE}" 4)"; NIC_STD_BOM_DESC="$(bom_field "${NIC_STD_BOM_LINE}" 5)"
NIC_OCP_BOM_PN="$(bom_field "${NIC_OCP_BOM_LINE}" 3)"; NIC_OCP_BOM_BATCH="$(bom_field "${NIC_OCP_BOM_LINE}" 4)"; NIC_OCP_BOM_DESC="$(bom_field "${NIC_OCP_BOM_LINE}" 5)"
MB_BOM_PN="$(bom_field "${MB_BOM_LINE}" 3)"; MB_BOM_BATCH="$(bom_field "${MB_BOM_LINE}" 4)"; MB_BOM_DESC="$(bom_field "${MB_BOM_LINE}" 5)"
BP_BOM_PN="$(bom_field "${BP_BOM_LINE}" 3)"; BP_BOM_BATCH="$(bom_field "${BP_BOM_LINE}" 4)"; BP_BOM_DESC="$(bom_field "${BP_BOM_LINE}" 5)"
FRONT_FAN_BOM_PN="$(bom_field "${FRONT_FAN_BOM_LINE}" 3)"; FRONT_FAN_BOM_BATCH="$(bom_field "${FRONT_FAN_BOM_LINE}" 4)"; FRONT_FAN_BOM_DESC="$(bom_field "${FRONT_FAN_BOM_LINE}" 5)"
MID_FAN_BOM_PN="$(bom_field "${MID_FAN_BOM_LINE}" 3)"; MID_FAN_BOM_BATCH="$(bom_field "${MID_FAN_BOM_LINE}" 4)"; MID_FAN_BOM_DESC="$(bom_field "${MID_FAN_BOM_LINE}" 5)"
PSU_BOM_PN="$(bom_field "${PSU_BOM_LINE}" 3)"; PSU_BOM_BATCH="$(bom_field "${PSU_BOM_LINE}" 4)"; PSU_BOM_DESC="$(bom_field "${PSU_BOM_LINE}" 5)"
NIC_100G_BOM_PN="$(bom_field "${NIC_100G_BOM_LINE}" 3)"; NIC_100G_BOM_BATCH="$(bom_field "${NIC_100G_BOM_LINE}" 4)"; NIC_100G_BOM_DESC="$(bom_field "${NIC_100G_BOM_LINE}" 5)"
NIC_25G_BOM_PN="$(bom_field "${NIC_25G_BOM_LINE}" 3)"; NIC_25G_BOM_BATCH="$(bom_field "${NIC_25G_BOM_LINE}" 4)"; NIC_25G_BOM_DESC="$(bom_field "${NIC_25G_BOM_LINE}" 5)"
NIC_10G_BOM_PN="$(bom_field "${NIC_10G_BOM_LINE}" 3)"; NIC_10G_BOM_BATCH="$(bom_field "${NIC_10G_BOM_LINE}" 4)"; NIC_10G_BOM_DESC="$(bom_field "${NIC_10G_BOM_LINE}" 5)"

CPU_BOM_PN="$(sanitize_bom_value "${CPU_BOM_PN}")"; CPU_BOM_BATCH="$(sanitize_bom_value "${CPU_BOM_BATCH}")"; CPU_BOM_DESC="$(sanitize_bom_value "${CPU_BOM_DESC}")"
MEM_BOM_PN="$(sanitize_bom_value "${MEM_BOM_PN}")"; MEM_BOM_BATCH="$(sanitize_bom_value "${MEM_BOM_BATCH}")"; MEM_BOM_DESC="$(sanitize_bom_value "${MEM_BOM_DESC}")"
RAID_BOM_PN="$(sanitize_bom_value "${RAID_BOM_PN}")"; RAID_BOM_BATCH="$(sanitize_bom_value "${RAID_BOM_BATCH}")"; RAID_BOM_DESC="$(sanitize_bom_value "${RAID_BOM_DESC}")"
NIC_STD_BOM_PN="$(sanitize_bom_value "${NIC_STD_BOM_PN}")"; NIC_STD_BOM_BATCH="$(sanitize_bom_value "${NIC_STD_BOM_BATCH}")"; NIC_STD_BOM_DESC="$(sanitize_bom_value "${NIC_STD_BOM_DESC}")"
NIC_OCP_BOM_PN="$(sanitize_bom_value "${NIC_OCP_BOM_PN}")"; NIC_OCP_BOM_BATCH="$(sanitize_bom_value "${NIC_OCP_BOM_BATCH}")"; NIC_OCP_BOM_DESC="$(sanitize_bom_value "${NIC_OCP_BOM_DESC}")"
MB_BOM_PN="$(sanitize_bom_value "${MB_BOM_PN}")"; MB_BOM_BATCH="$(sanitize_bom_value "${MB_BOM_BATCH}")"; MB_BOM_DESC="$(sanitize_bom_value "${MB_BOM_DESC}")"
BP_BOM_PN="$(sanitize_bom_value "${BP_BOM_PN}")"; BP_BOM_BATCH="$(sanitize_bom_value "${BP_BOM_BATCH}")"; BP_BOM_DESC="$(sanitize_bom_value "${BP_BOM_DESC}")"
FRONT_FAN_BOM_PN="$(sanitize_bom_value "${FRONT_FAN_BOM_PN}")"; FRONT_FAN_BOM_BATCH="$(sanitize_bom_value "${FRONT_FAN_BOM_BATCH}")"; FRONT_FAN_BOM_DESC="$(sanitize_bom_value "${FRONT_FAN_BOM_DESC}")"
MID_FAN_BOM_PN="$(sanitize_bom_value "${MID_FAN_BOM_PN}")"; MID_FAN_BOM_BATCH="$(sanitize_bom_value "${MID_FAN_BOM_BATCH}")"; MID_FAN_BOM_DESC="$(sanitize_bom_value "${MID_FAN_BOM_DESC}")"
PSU_BOM_PN="$(sanitize_bom_value "${PSU_BOM_PN}")"; PSU_BOM_BATCH="$(sanitize_bom_value "${PSU_BOM_BATCH}")"; PSU_BOM_DESC="$(sanitize_bom_value "${PSU_BOM_DESC}")"
NIC_100G_BOM_PN="$(sanitize_bom_value "${NIC_100G_BOM_PN}")"; NIC_100G_BOM_BATCH="$(sanitize_bom_value "${NIC_100G_BOM_BATCH}")"; NIC_100G_BOM_DESC="$(sanitize_bom_value "${NIC_100G_BOM_DESC}")"
NIC_25G_BOM_PN="$(sanitize_bom_value "${NIC_25G_BOM_PN}")"; NIC_25G_BOM_BATCH="$(sanitize_bom_value "${NIC_25G_BOM_BATCH}")"; NIC_25G_BOM_DESC="$(sanitize_bom_value "${NIC_25G_BOM_DESC}")"
NIC_10G_BOM_PN="$(sanitize_bom_value "${NIC_10G_BOM_PN}")"; NIC_10G_BOM_BATCH="$(sanitize_bom_value "${NIC_10G_BOM_BATCH}")"; NIC_10G_BOM_DESC="$(sanitize_bom_value "${NIC_10G_BOM_DESC}")"

BASEBOARD_NAME="$(value_by_key "${RAW_DIR}/dmidecode_baseboard.txt" "^[[:space:]]*Product Name:[[:space:]]*")"
BASEBOARD_MFG="$(value_by_key "${RAW_DIR}/dmidecode_baseboard.txt" "^[[:space:]]*Manufacturer:[[:space:]]*")"
BASEBOARD_VER="$(value_by_key "${RAW_DIR}/dmidecode_baseboard.txt" "^[[:space:]]*Version:[[:space:]]*")"

MB_CPLD_VER="$(firmware_value "BCU1CpuBoard1CPLD1" "Version")"; [[ -z "${MB_CPLD_VER}" ]] && MB_CPLD_VER="N/A"
FRONT_FAN_CPLD_VER="$(firmware_value "CLU1FanBoard1CPLD" "Version")"; [[ -z "${FRONT_FAN_CPLD_VER}" ]] && FRONT_FAN_CPLD_VER="N/A"
MID_FAN_CPLD_VER="$(firmware_value "CLU2FanBoard2CPLD" "Version")"; [[ -z "${MID_FAN_CPLD_VER}" ]] && MID_FAN_CPLD_VER="N/A"
FAN_CPLD_VER="${FRONT_FAN_CPLD_VER}/${MID_FAN_CPLD_VER}"
SCM_CPLD_VER="$(firmware_value "ActiveBMC" "Version")"; [[ -z "${SCM_CPLD_VER}" ]] && SCM_CPLD_VER="N/A"
DISK_BP1_CPLD_VER="$(firmware_value "SEU1DiskBP1CPLD" "Version")"; [[ -z "${DISK_BP1_CPLD_VER}" ]] && DISK_BP1_CPLD_VER="N/A"
DISK_BP2_CPLD_VER="$(firmware_value "SEU2DiskBP2CPLD" "Version")"; [[ -z "${DISK_BP2_CPLD_VER}" ]] && DISK_BP2_CPLD_VER="N/A"
DISK_BP3_CPLD_VER="$(firmware_value "SEU3DiskBP3CPLD" "Version")"; [[ -z "${DISK_BP3_CPLD_VER}" ]] && DISK_BP3_CPLD_VER="N/A"
PSU_BOARD_VER="$(firmware_value "chassisPSUBoard1HWSR" "Version")"; [[ -z "${PSU_BOARD_VER}" ]] && PSU_BOARD_VER="N/A"
EXP_CPLD_VER="$(firmware_value "EXU1ExpBoard1CPLD" "Version")"; [[ -z "${EXP_CPLD_VER}" ]] && EXP_CPLD_VER="N/A"
BIOS_FW_VER="$(firmware_value "Bios" "Version")"; [[ -z "${BIOS_FW_VER}" ]] && BIOS_FW_VER="N/A"
NIC_SF221Q_CSR_VER="$(firmware_value "chassisNIC1(SF221Q)HWSR" "Version")"; [[ -z "${NIC_SF221Q_CSR_VER}" ]] && NIC_SF221Q_CSR_VER="N/A"
NIC_SF223D_CSR_VER="$(firmware_value "chassisNIC2(SF223D-H)HWSR" "Version")"; [[ -z "${NIC_SF223D_CSR_VER}" ]] && NIC_SF223D_CSR_VER="N/A"
BP_PRESENT="0"
[[ "${DISK_BP1_CPLD_VER}" != "N/A" || "${DISK_BP2_CPLD_VER}" != "N/A" || "${DISK_BP3_CPLD_VER}" != "N/A" ]] && BP_PRESENT="1"
NVME_BP_QTY=0
for bp_ver in "${DISK_BP1_CPLD_VER}" "${DISK_BP2_CPLD_VER}" "${DISK_BP3_CPLD_VER}"; do
  [[ "${bp_ver}" != "N/A" ]] && NVME_BP_QTY=$((NVME_BP_QTY + 1))
done

FIRMWARE_SUMMARY_ROWS=""
if compgen -G "${RAW_DIR}/redfish_fw_*.txt" >/dev/null; then
  while IFS= read -r fw_file; do
    fw_id="$(json_value_by_key "${fw_file}" "Id")"
    fw_name="$(json_value_by_key "${fw_file}" "Name")"
    fw_ver="$(json_value_by_key "${fw_file}" "Version")"
    [[ -z "${fw_id}" ]] && fw_id="$(basename "${fw_file}" .txt | sed 's/^redfish_fw_//')"
    [[ -z "${fw_name}" ]] && fw_name="${fw_id}"
    [[ -z "${fw_ver}" ]] && fw_ver="N/A"
    FIRMWARE_SUMMARY_ROWS="${FIRMWARE_SUMMARY_ROWS}| ${fw_id} | ${fw_name} | ${fw_ver} |\n"
  done < <(printf '%s\n' "${RAW_DIR}"/redfish_fw_*.txt | sort)
fi

NIC_SUMMARY_ROWS="$(
  strip_capture_header "${RAW_DIR}/lspci.txt" 2>/dev/null | awk -F': ' '/Ethernet controller:/ {print $2}' | sort | uniq -c |
  awk '{count=$1; $1=""; sub(/^[[:space:]]+/, "", $0); printf("| NIC | %s | %s |\n", $0, count)}'
)"
RAID_SUMMARY_ROWS="$(
  strip_capture_header "${RAW_DIR}/lspci.txt" 2>/dev/null | awk -F': ' '/RAID bus controller:/ {print $2}' | sort | uniq -c |
  awk '{count=$1; $1=""; sub(/^[[:space:]]+/, "", $0); printf("| RAID | %s | %s |\n", $0, count)}'
)"
ACCEL_SUMMARY_ROWS="$(
  strip_capture_header "${RAW_DIR}/lspci.txt" 2>/dev/null | awk -F': ' '/Processing accelerators:/ {print $2}' | sort | uniq -c |
  awk '{count=$1; $1=""; sub(/^[[:space:]]+/, "", $0); printf("| Accelerator | %s | %s |\n", $0, count)}'
)"
STORAGE_CTRL_ROWS="$(
  strip_capture_header "${RAW_DIR}/lspci.txt" 2>/dev/null | awk -F': ' '/Serial Attached SCSI controller:|SATA controller:|Non-Volatile memory controller:/ {print $2}' | sort | uniq -c |
  awk '{count=$1; $1=""; sub(/^[[:space:]]+/, "", $0); printf("| Storage | %s | %s |\n", $0, count)}'
)"

NIC_PHYSICAL_ROWS_ZH="$(
  strip_capture_header "${RAW_DIR}/lspci.txt" 2>/dev/null | awk '
    /Ethernet controller:/ {
      split($1, a, ".")
      slot=a[1]
      desc=$0
      sub(/^[^:]+: Ethernet controller: /, "", desc)
      cnt[slot]++
      name[slot]=desc
    }
    END {
      for (slot in cnt) {
        printf("%s\t%d\t%s\n", slot, cnt[slot], name[slot])
      }
    }
  ' | sort | while IFS=$'\t' read -r slot fn_count desc; do
    [[ -z "${slot:-}" ]] && continue
    if [[ "${desc}" == *"Device 0222"* ]]; then
      nic_desc="${NIC_100G_BOM_DESC:-100G双口PCIe网卡}"
      printf '| PCIe NIC | %s | %s | %s |  |  | PCIe | 1 | 来自当前环境物理卡识别：%s，函数数 %s |\n' \
        "${NIC_100G_BOM_PN:-}" "${NIC_100G_BOM_BATCH:-}" "${nic_desc}" "${slot}" "${fn_count}"
    elif [[ "${desc}" == *"HNS GE/10GE/25GE/50GE RDMA Network Controller"* && "${fn_count}" == "4" ]]; then
      nic_desc="${NIC_10G_BOM_DESC:-四口10G电口灵活网卡}"
      nic_fw=""
      [[ "${NIC_SF221Q_CSR_VER}" != "N/A" ]] && nic_fw="${NIC_SF221Q_CSR_VER}"
      printf '| OCP NIC | %s | %s | %s | %s |  | OCP/Flex | 1 | 来自当前环境物理卡识别：%s，4口 |\n' \
        "${NIC_10G_BOM_PN:-}" "${NIC_10G_BOM_BATCH:-}" "${nic_desc}" "${nic_fw}" "${slot}"
    elif [[ "${desc}" == *"HNS GE/10GE/25GE/50GE RDMA Network Controller"* && "${fn_count}" == "2" ]]; then
      nic_desc="${NIC_25G_BOM_DESC:-2口25G光口灵活网卡}"
      nic_fw=""
      [[ "${NIC_SF223D_CSR_VER}" != "N/A" ]] && nic_fw="${NIC_SF223D_CSR_VER}"
      printf '| OCP NIC | %s | %s | %s | %s |  | OCP/Flex | 1 | 来自当前环境物理卡识别：%s，2口 |\n' \
        "${NIC_25G_BOM_PN:-}" "${NIC_25G_BOM_BATCH:-}" "${nic_desc}" "${nic_fw}" "${slot}"
    else
      printf '| NIC |  |  | %s |  |  | PCIe/OCP | 1 | 来自当前环境物理卡识别：%s，函数数 %s |\n' \
        "${desc}" "${slot}" "${fn_count}"
    fi
  done
)"

NIC_PHYSICAL_SUMMARY_ROWS="$(
  printf "%s\n" "${NIC_PHYSICAL_ROWS_ZH}" | awk -F'|' '
    NF >= 9 {
      category=$2; desc=$5
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", category)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", desc)
      if (category != "" && desc != "") {
        key=category "\t" desc
        cnt[key]++
      }
    }
    END {
      for (k in cnt) {
        split(k, a, "\t")
        printf("| %s | %s | %d |\n", a[1], a[2], cnt[k])
      }
    }
  ' | sort
)"

log "INFO" "Stage: render core outputs"
cat > "${OUT_DIR}/software_info.md" <<EOF
# Software Info

| Category | Version | Release Date | Notes |
|---|---|---|---|
| OS | ${OS_NAME} | N/A | Kernel: ${KERNEL_VER} |
| GCC | ${GCC_VER} | N/A | auto collected |
| BIOS | ${BIOS_VER} | N/A | dmidecode; inventory version: ${BIOS_FW_VER} |
| BMC | ${BMC_VER} | N/A | ${BMC_SRC_NOTE} |
| MB CPLD | ${MB_CPLD_VER} | N/A | Redfish FirmwareInventory |
| Front FAN CPLD | ${FRONT_FAN_CPLD_VER} | N/A | Redfish FirmwareInventory |
| Mid FAN CPLD | ${MID_FAN_CPLD_VER} | N/A | Redfish FirmwareInventory |
| SCM CPLD | ${SCM_CPLD_VER} | N/A | Redfish FirmwareInventory approximate |
| Other FW | see firmware_inventory.md | N/A | see raw logs |
EOF

{
  echo "# Tools Info"
  echo
  echo "| Name | Version | Description | Source |"
  echo "|---|---|---|---|"
  for t in gcc ipmitool lspci nvme smartctl; do
    if has_cmd "${t}"; then
      echo "| ${t} | installed | tool detected | host |"
    else
      echo "| ${t} | not installed | tool missing | host |"
    fi
  done
} > "${OUT_DIR}/tools_info.md"

{
  echo "# Component Spec"
  echo
  echo "## CPU"
  echo "- Manufacturer: ${CPU_VENDOR:-N/A}"
  echo "- Model: ${CPU_MODEL:-N/A}"
  echo "- Performance: ${CPU_PHYSICAL_CORES} cores / ${CPU_THREADS:-N/A} threads"
  echo "- Frequency: ${CPU_MAX_MHZ:-N/A} MHz (max)"
  echo "- Cache: L3 ${CPU_L3_CACHE:-N/A}"
  echo
  echo "## Memory"
  echo "- Manufacturer: ${MEM_VENDOR:-N/A}"
  echo "- Capacity: ${MEM_TOTAL}"
  echo "- Bandwidth/Speed: ${MEM_SPEED:-N/A}"
  echo "- DIMM Count: ${DIMM_COUNT}"
  echo
  echo "## NVMe/SATA Disks"
  echo
  echo "| NAME | MODEL | SERIAL | SIZE | ROTA | TYPE |"
  echo "|---|---|---|---|---:|---|"
  awk '
    /^#/ || NF==0 {next}
    /NAME="/ {
      name=model=serial=size=rota=type=""
      if (match($0, /NAME="[^"]*"/))   {name=substr($0, RSTART+6, RLENGTH-7)}
      if (match($0, /MODEL="[^"]*"/))  {model=substr($0, RSTART+7, RLENGTH-8)}
      if (match($0, /SERIAL="[^"]*"/)) {serial=substr($0, RSTART+8, RLENGTH-9)}
      if (match($0, /SIZE="[^"]*"/))   {size=substr($0, RSTART+6, RLENGTH-7)}
      if (match($0, /ROTA="[^"]*"/))   {rota=substr($0, RSTART+6, RLENGTH-7)}
      if (match($0, /TYPE="[^"]*"/))   {type=substr($0, RSTART+6, RLENGTH-7)}
      printf("| %s | %s | %s | %s | %s | %s |\n", name, model, serial, size, rota, type)
    }
  ' "${RAW_DIR}/lsblk.txt"
} > "${OUT_DIR}/component_spec.md"

{
  echo "# Component Info Prefill"
  echo
  echo "| Category | Part No. | Batch No. | Description | Firmware | Driver | Location | Qty | Notes |"
  echo "|---|---|---|---|---|---|---|---:|---|"
  echo "| CPU |  |  | ${CPU_MODEL:-N/A} |  |  | CPU Socket | ${CPU_SOCKETS:-N/A} | host detected |"
  echo "| MEM |  |  | ${MEM_VENDOR:-N/A} Memory |  |  | DIMM | ${DIMM_COUNT} | host detected |"
} > "${OUT_DIR}/component_info_prefill.md"

{
  echo "# Board Info Prefill"
  echo
  echo "| Category | Part No. | Batch No. | Description | Location | Version | Qty | Notes |"
  echo "|---|---|---|---|---|---|---:|---|"
  echo "| MB |  |  | ${BASEBOARD_MFG:-} ${BASEBOARD_NAME:-} | - | ${BASEBOARD_VER:-N/A} | 1 | from dmidecode |"
  echo "| SCM Card |  |  | BMC/SCM board | rear | ${BMC_VER} | 1 | from Redfish/IPMI |"
} > "${OUT_DIR}/board_info_prefill.md"

{
  echo "# Firmware Inventory"
  echo
  echo "| ID | Name | Version |"
  echo "|---|---|---|"
  if [[ -n "${FIRMWARE_SUMMARY_ROWS}" ]]; then
    printf "%b" "${FIRMWARE_SUMMARY_ROWS}"
  else
    echo "| N/A | No Redfish firmware inventory details collected | N/A |"
  fi
} > "${OUT_DIR}/firmware_inventory.md"

{
  echo "# PCIe Device Summary"
  echo
  echo "| Type | Description | Qty |"
  echo "|---|---|---:|"
  [[ -n "${NIC_PHYSICAL_SUMMARY_ROWS}" ]] && printf "%s\n" "${NIC_PHYSICAL_SUMMARY_ROWS}"
  [[ -z "${NIC_PHYSICAL_SUMMARY_ROWS}" && -n "${NIC_SUMMARY_ROWS}" ]] && printf "%s\n" "${NIC_SUMMARY_ROWS}"
  [[ -n "${RAID_SUMMARY_ROWS}" ]] && printf "%s\n" "${RAID_SUMMARY_ROWS}"
  [[ -n "${ACCEL_SUMMARY_ROWS}" ]] && printf "%s\n" "${ACCEL_SUMMARY_ROWS}"
  [[ -n "${STORAGE_CTRL_ROWS}" ]] && printf "%s\n" "${STORAGE_CTRL_ROWS}"
} > "${OUT_DIR}/pcie_device_summary.md"

{
  echo "# Final Baseline Template"
  echo
  echo "## Software"
  cat "${OUT_DIR}/software_info.md"
  echo
  echo "## Component Spec"
  cat "${OUT_DIR}/component_spec.md"
  echo
  echo "## Board Prefill"
  cat "${OUT_DIR}/board_info_prefill.md"
} > "${OUT_DIR}/final_baseline_template.md"

log "INFO" "Stage: render zh outputs"
{
  echo "# 基准配置填写_软件信息"
  echo
  echo "| 类别 | 版本 | 发布时间 | 备注 |"
  echo "|---|---|---|---|"
  echo "| OS | ${OS_NAME} |  | Kernel: ${KERNEL_VER} |"
  echo "| GCC | ${GCC_VER} |  | 自动采集 |"
  echo "| BIOS | ${BIOS_VER} |  | dmidecode；固件库存版本 ${BIOS_FW_VER} |"
  echo "| BMC | ${BMC_VER} |  | ${BMC_SRC_NOTE} |"
  echo "| MB CPLD | ${MB_CPLD_VER} |  | Redfish FirmwareInventory |"
  echo "| Front FAN CPLD | ${FRONT_FAN_CPLD_VER} |  | Redfish FirmwareInventory |"
  echo "| Mid FAN CPLD | ${MID_FAN_CPLD_VER} |  | Redfish FirmwareInventory |"
  echo "| SCM CPLD | ${SCM_CPLD_VER} |  | Redfish FirmwareInventory 近似映射 |"
  echo "| Disk BP1 CPLD | ${DISK_BP1_CPLD_VER} |  | Redfish FirmwareInventory |"
  echo "| Disk BP2 CPLD | ${DISK_BP2_CPLD_VER} |  | Redfish FirmwareInventory |"
  echo "| Disk BP3 CPLD | ${DISK_BP3_CPLD_VER} |  | Redfish FirmwareInventory |"
  echo "| PSU Board CSR | ${PSU_BOARD_VER} |  | Redfish FirmwareInventory |"
} > "${OUT_DIR}/software_info_zh.md"

{
  echo "# 基准配置填写_板卡信息"
  echo
  echo "| 类别 | 物料号 | 批次号 | 物料描述 | 位置 | 版本 | 数量 | 备注（*为必填项） |"
  echo "|---|---|---|---|---|---|---:|---|"
  echo "| MB | ${MB_BOM_PN:-} | ${MB_BOM_BATCH:-} | ${MB_BOM_DESC:-${BASEBOARD_MFG:-} ${BASEBOARD_NAME:-}} | - | ${BASEBOARD_VER:-N/A} | 1 | *SN 待人工补；来源 BOM+dmidecode |"
  if [[ "${BP_PRESENT}" == "1" ]]; then
    echo "| SATA BP | ${BP_BOM_PN:-} | ${BP_BOM_BATCH:-} | ${BP_BOM_DESC:-Disk Backplane} | 前置 | ${DISK_BP1_CPLD_VER}/${DISK_BP2_CPLD_VER}/${DISK_BP3_CPLD_VER} | 3 | 当前环境检测到背板固件，BOM 仅补料号 |"
  fi
  echo "| Mid Riser |  |  | Mid/IO Riser | 中置/后置 | ${EXP_CPLD_VER} |  | 需结合实物标签确认 |"
  echo "| FAN BP |  |  | Fan board | 内置 | ${FAN_CPLD_VER} | 2 | 当前环境检测到 2 个风扇板；BOM 不参与存在性判断 |"
  echo "| SCM Card |  |  | BMC/SCM board | 后置 | ${BMC_VER} | 1 | 版本来自 Redfish /Managers/1 |"
  echo "| PSU Board |  |  | PSU board | 电源区域 | ${PSU_BOARD_VER} | 2 | 版本来自 Redfish；不使用 PSU 模块 BOM 近似替代 |"
} > "${OUT_DIR}/board_info_zh.md"

{
  echo "# 基准配置填写_板卡信息"
  echo
  echo "| 类别 | 物料号 | 批次号 | 物料描述 | 位置 | 版本 | 数量 | 备注（*为必填项） |"
  echo "|---|---|---|---|---|---|---:|---|"
  echo "| MB | ${MB_BOM_PN:-} | ${MB_BOM_BATCH:-} | ${MB_BOM_DESC:-${BASEBOARD_MFG:-} ${BASEBOARD_NAME:-}} | - | ${BASEBOARD_VER:-N/A} | 1 | *SN 待人工补 |"
  if [[ "${BP_PRESENT}" == "1" ]]; then
    echo "| NVMe BP |  |  | NVMe Disk Backplane | 前置 | ${DISK_BP1_CPLD_VER}/${DISK_BP2_CPLD_VER}/${DISK_BP3_CPLD_VER} | ${NVME_BP_QTY} | 当前环境为 NVMe 背板，不沿用 SATA 背板 BOM |"
  fi
  echo "| Mid Riser |  |  | Mid/IO Riser | 中置/后置 | ${EXP_CPLD_VER} |  | 需结合实物标签确认 |"
  if [[ "${FRONT_FAN_CPLD_VER}" != "N/A" ]]; then
    echo "| FAN BP | ${FRONT_FAN_BOM_PN:-} | ${FRONT_FAN_BOM_BATCH:-} | ${FRONT_FAN_BOM_DESC:-前置风扇板} | 前置 | ${FRONT_FAN_CPLD_VER} | 1 | 前置风扇板，单独列示 |"
  fi
  if [[ "${MID_FAN_CPLD_VER}" != "N/A" ]]; then
    echo "| FAN BP | ${MID_FAN_BOM_PN:-} | ${MID_FAN_BOM_BATCH:-} | ${MID_FAN_BOM_DESC:-中置风扇板} | 中置 | ${MID_FAN_CPLD_VER} | 1 | 中置风扇板，单独列示 |"
  fi
  echo "| SCM Card |  |  | BMC/SCM board | 后置 | ${BMC_VER} | 1 |  |"
  echo "| PSU Board |  |  | PSU board | 电源区域 | ${PSU_BOARD_VER} | 2 |  |"
} > "${OUT_DIR}/board_info_zh.md"

{
  echo "# 基准配置填写_部件信息"
  echo
  echo "| 类别 | 物料号 | 批次号 | 物料描述 | Firmware | Driver | 位置 | 数量 | 备注 |"
  echo "|---|---|---|---|---|---|---|---:|---|"
  echo "| CPU |  |  | ${CPU_MODEL:-N/A} |  |  | CPU Socket | ${CPU_SOCKETS:-N/A} |  |"
  echo "| MEM | ${MEM_BOM_PN:-} | ${MEM_BOM_BATCH:-} | ${MEM_BOM_DESC:-${MEM_VENDOR:-N/A} Memory} |  |  | DIMM | ${DIMM_COUNT} | 总容量 ${MEM_TOTAL} |"
  awk '
    /^#/ || NF==0 {next}
    /NAME="nvme[0-9]+n[0-9]+"/ {
      name=model=serial=size=""
      if (match($0, /NAME="[^"]*"/))   {name=substr($0, RSTART+6, RLENGTH-7)}
      if (match($0, /MODEL="[^"]*"/))  {model=substr($0, RSTART+7, RLENGTH-8)}
      if (match($0, /SERIAL="[^"]*"/)) {serial=substr($0, RSTART+8, RLENGTH-9)}
      if (match($0, /SIZE="[^"]*"/))   {size=substr($0, RSTART+6, RLENGTH-7)}
      printf("| NVMe SSD |  |  | %s |  | nvme | PCIe/NVMe | 1 | /dev/%s %s %s |\n", model, name, serial, size)
    }
  ' "${RAW_DIR}/lsblk.txt"
  if [[ -n "${RAID_SUMMARY_ROWS}" ]]; then
    printf "%s\n" "${RAID_SUMMARY_ROWS}" | awk -F'|' -v pn="${RAID_BOM_PN:-}" -v batch="${RAID_BOM_BATCH:-}" -v desc_map="${RAID_BOM_DESC:-}" '
      NF >= 4 {
        desc=$3; qty=$4
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", desc)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", qty)
        if (desc ~ /SP686C/ && desc_map != "") {
          printf("| RAID | %s | %s | %s |  |  | PCIe | %s |  |\n", pn, batch, desc_map, qty)
        } else {
          printf("| RAID |  |  | %s |  |  | PCIe | %s |  |\n", desc, qty)
        }
      }'
  fi
  if [[ -n "${NIC_SUMMARY_ROWS}" ]]; then
    printf "%s\n" "${NIC_SUMMARY_ROWS}" | awk -F'|' '
      NF >= 4 {
        desc=$3; qty=$4
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", desc)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", qty)
        printf("| NIC |  |  | %s |  |  | PCIe/OCP | %s |  |\n", desc, qty)
      }'
  fi
} > "${OUT_DIR}/component_info_zh.md"

{
  echo "# 基准配置填写_部件信息"
  echo
  echo "| 类别 | 物料号 | 批次号 | 物料描述 | Firmware | Driver | 位置 | 数量 | 备注 |"
  echo "|---|---|---|---|---|---|---|---:|---|"
  echo "| CPU |  |  | ${CPU_MODEL:-N/A} |  |  | CPU Socket | ${CPU_SOCKETS:-N/A} | CPU 型号以当前环境识别为准；未找到可直接对应的 BOM CPU 行 |"
  echo "| MEM | ${MEM_BOM_PN:-} | ${MEM_BOM_BATCH:-} | ${MEM_BOM_DESC:-${MEM_VENDOR:-N/A} Memory} |  |  | DIMM | ${DIMM_COUNT} | 总容量 ${MEM_TOTAL}；BOM 仅补单条料号信息 |"
  awk '
    /^#/ || NF==0 {next}
    /NAME="nvme[0-9]+n[0-9]+"/ {
      name=model=serial=size=""
      if (match($0, /NAME="[^"]*"/))   {name=substr($0, RSTART+6, RLENGTH-7)}
      if (match($0, /MODEL="[^"]*"/))  {model=substr($0, RSTART+7, RLENGTH-8)}
      if (match($0, /SERIAL="[^"]*"/)) {serial=substr($0, RSTART+8, RLENGTH-9)}
      if (match($0, /SIZE="[^"]*"/))   {size=substr($0, RSTART+6, RLENGTH-7)}
      printf("| NVMe SSD |  |  | %s |  | nvme | PCIe/NVMe | 1 | /dev/%s %s %s |\n", model, name, serial, size)
    }
  ' "${RAW_DIR}/lsblk.txt"
  if [[ -n "${RAID_SUMMARY_ROWS}" ]]; then
    printf "%s\n" "${RAID_SUMMARY_ROWS}" | awk -F'|' -v pn="${RAID_BOM_PN:-}" -v batch="${RAID_BOM_BATCH:-}" -v desc_map="${RAID_BOM_DESC:-}" '
      NF >= 4 {
        desc=$3; qty=$4
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", desc)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", qty)
        if (desc ~ /SP686C/ && desc_map != "") {
          printf("| RAID | %s | %s | %s |  |  | PCIe | %s | 当前环境检测到 RAID；BOM 补料号 |\n", pn, batch, desc_map, qty)
        } else {
          printf("| RAID |  |  | %s |  |  | PCIe | %s | 仅按当前环境汇总 |\n", desc, qty)
        }
      }'
  fi
  if [[ -n "${NIC_PHYSICAL_ROWS_ZH}" ]]; then
    printf "%s\n" "${NIC_PHYSICAL_ROWS_ZH}"
  elif [[ -n "${NIC_SUMMARY_ROWS}" ]]; then
    printf "%s\n" "${NIC_SUMMARY_ROWS}" | awk -F'|' '
      NF >= 4 {
        desc=$3; qty=$4
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", desc)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", qty)
        printf("| NIC |  |  | %s |  |  | PCIe/OCP | %s | 当前环境汇总；未做强制 BOM 映射 |\n", desc, qty)
      }'
  fi
} > "${OUT_DIR}/component_info_zh.md"

{
  echo "# 固件清单"
  echo
  echo "| 类别 | 名称 | 版本 |"
  echo "|---|---|---|"
  if [[ -n "${FIRMWARE_SUMMARY_ROWS}" ]]; then
    printf "%b" "${FIRMWARE_SUMMARY_ROWS}" | awk -F'|' '
      NF >= 4 {
        id=$2; name=$3; ver=$4
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", ver)
        printf("| %s | %s | %s |\n", id, name, ver)
      }'
  else
    echo "| N/A | 未采集到固件清单 | N/A |"
  fi
} > "${OUT_DIR}/firmware_inventory_zh.md"

{
  echo "# Final Baseline Template Zh"
  echo
  echo "## Software Info"
  cat "${OUT_DIR}/software_info_zh.md"
  echo
  echo "## Board Info"
  cat "${OUT_DIR}/board_info_zh.md"
  echo
  echo "## Component Info"
  cat "${OUT_DIR}/component_info_zh.md"
  echo
  echo "## Firmware Inventory"
  cat "${OUT_DIR}/firmware_inventory_zh.md"
} > "${OUT_DIR}/final_baseline_template_zh.md"

log "INFO" "Stage: render html"
markdown_table_to_html "${OUT_DIR}/software_info_zh.md" "基准配置填写_软件信息" "${OUT_DIR}/software_info_zh.html"
markdown_table_to_html "${OUT_DIR}/board_info_zh.md" "基准配置填写_板卡信息" "${OUT_DIR}/board_info_zh.html"
markdown_table_to_html "${OUT_DIR}/component_info_zh.md" "基准配置填写_部件信息" "${OUT_DIR}/component_info_zh.html"
markdown_table_to_html "${OUT_DIR}/firmware_inventory_zh.md" "Firmware Inventory Zh" "${OUT_DIR}/firmware_inventory_zh.html"
markdown_table_to_html "${OUT_DIR}/pcie_device_summary.md" "PCIe Device Summary" "${OUT_DIR}/pcie_device_summary.html"
cp -f "${OUT_DIR}/software_info_zh.html" "${OUT_DIR}/基准配置填写_软件信息.html"
cp -f "${OUT_DIR}/board_info_zh.html" "${OUT_DIR}/基准配置填写_板卡信息.html"
cp -f "${OUT_DIR}/component_info_zh.html" "${OUT_DIR}/基准配置填写_部件信息.html"

{
  echo '<!DOCTYPE html>'
  echo '<html lang="zh-CN">'
  echo '<head>'
  echo '  <meta charset="UTF-8">'
  echo '  <title>Final Baseline Template Zh</title>'
  echo '  <style>'
  echo '    body { font-family: "Microsoft YaHei", "PingFang SC", Arial, sans-serif; margin: 12px; color: #333; background: #fff; }'
  echo '    h1 { font-size: 20px; margin: 0 0 12px; }'
  echo '    h2 { font-size: 16px; margin: 22px 0 8px; }'
  echo '    table { border-collapse: collapse; width: 100%; table-layout: auto; margin-bottom: 18px; }'
  echo '    th, td { border: 1px solid #cfd6df; padding: 8px 10px; font-size: 14px; vertical-align: top; word-break: break-word; }'
  echo '    th { background: #eef2f6; font-weight: 700; text-align: left; }'
  echo '    tr:nth-child(even) td { background: #fafbfd; }'
  echo '    .wrap { max-width: 1600px; }'
  echo '  </style>'
  echo '</head>'
  echo '<body>'
  echo '  <div class="wrap">'
  echo '    <h1>Final Baseline Template Zh</h1>'
  for section in software_info_zh board_info_zh component_info_zh firmware_inventory_zh; do
    title="$(sed -n '1s/^# //p' "${OUT_DIR}/${section}.md")"
    echo "    <h2>${title}</h2>"
    awk '
      function esc(s) {
        gsub(/&/, "\\&amp;", s); gsub(/</, "\\&lt;", s); gsub(/>/, "\\&gt;", s); return s
      }
      BEGIN { row=0; print "    <table>" }
      /^\|/ {
        line=$0
        gsub(/\r/, "", line)
        if (line ~ /^\|---/) next
        sub(/^\|/, "", line); sub(/\|$/, "", line)
        n=split(line, a, /\|/); row++
        if (row == 1) {
          print "      <thead><tr>"
          for (i=1; i<=n; i++) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", a[i]); printf "        <th>%s</th>\n", esc(a[i]) }
          print "      </tr></thead>"; print "      <tbody>"
        } else {
          print "      <tr>"
          for (i=1; i<=n; i++) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", a[i]); printf "        <td>%s</td>\n", esc(a[i]) }
          print "      </tr>"
        }
      }
      END { if (row >= 1) print "      </tbody>"; print "    </table>" }
    ' "${OUT_DIR}/${section}.md"
  done
  echo '  </div>'
  echo '</body>'
  echo '</html>'
} > "${OUT_DIR}/final_baseline_template_zh.html"

log "INFO" "Stage: normalize zh outputs"
{
  echo "# 基准配置填写_软件信息"
  echo
  echo "| 类别 | 版本 | 发布时间 | 备注 |"
  echo "|---|---|---|---|"
  echo "| OS | ${OS_NAME} |  | Kernel: ${KERNEL_VER} |"
  echo "| GCC | ${GCC_VER} |  | 自动采集 |"
  echo "| BIOS | ${BIOS_VER} |  | dmidecode；固件库存版本：${BIOS_FW_VER} |"
  echo "| BMC | ${BMC_VER} |  | from Redfish /Managers/1 |"
  echo "| MB CPLD | ${MB_CPLD_VER} |  | Redfish FirmwareInventory |"
  echo "| 前置 FAN CPLD | ${FRONT_FAN_CPLD_VER} |  | Redfish FirmwareInventory |"
  echo "| 中置 FAN CPLD | ${MID_FAN_CPLD_VER} |  | Redfish FirmwareInventory |"
  echo "| SCM CPLD | ${SCM_CPLD_VER} |  | Redfish FirmwareInventory 近似映射 |"
  echo "| NVMe BP1 CPLD | ${DISK_BP1_CPLD_VER} |  | Redfish FirmwareInventory |"
  echo "| NVMe BP2 CPLD | ${DISK_BP2_CPLD_VER} |  | Redfish FirmwareInventory |"
  echo "| NVMe BP3 CPLD | ${DISK_BP3_CPLD_VER} |  | Redfish FirmwareInventory |"
  echo "| PSU Board CSR | ${PSU_BOARD_VER} |  | Redfish FirmwareInventory |"
} > "${OUT_DIR}/software_info_zh.md"

{
  echo "# 基准配置填写_板卡信息"
  echo
  echo "| 类别 | 物料号 | 批次号 | 物料描述 | 位置 | 版本 | 数量 | 备注（*为必填项） |"
  echo "|---|---|---|---|---|---|---:|---|"
  echo "| MB | ${MB_BOM_PN:-} | ${MB_BOM_BATCH:-} | ${MB_BOM_DESC:-${BASEBOARD_MFG:-} ${BASEBOARD_NAME:-}} | - | ${BASEBOARD_VER:-N/A} | 1 | *SN 待人工补；来源：BOM+dmidecode |"
  if [[ "${BP_PRESENT}" == "1" ]]; then
    echo "| NVMe BP |  |  | NVMe Disk Backplane | 前置 | ${DISK_BP1_CPLD_VER}/${DISK_BP2_CPLD_VER}/${DISK_BP3_CPLD_VER} | ${NVME_BP_QTY} | 当前环境为 NVMe 背板，不沿用 SATA 背板 BOM |"
  fi
  echo "| Mid Riser |  |  | Mid/IO Riser | 中置/后置 | ${EXP_CPLD_VER} |  | 需结合实物标签确认 |"
  if [[ "${FRONT_FAN_CPLD_VER}" != "N/A" ]]; then
    echo "| FAN BP | ${FRONT_FAN_BOM_PN:-} | ${FRONT_FAN_BOM_BATCH:-} | ${FRONT_FAN_BOM_DESC:-前置风扇板} | 前置 | ${FRONT_FAN_CPLD_VER} | 1 | 前置风扇板，单独列示 |"
  fi
  if [[ "${MID_FAN_CPLD_VER}" != "N/A" ]]; then
    echo "| FAN BP | ${MID_FAN_BOM_PN:-} | ${MID_FAN_BOM_BATCH:-} | ${MID_FAN_BOM_DESC:-中置风扇板} | 中置 | ${MID_FAN_CPLD_VER} | 1 | 中置风扇板，单独列示 |"
  fi
  echo "| SCM Card |  |  | BMC/SCM board | 后置 | ${BMC_VER} | 1 | 版本来自 Redfish /Managers/1 |"
  echo "| PSU Board |  |  | PSU board | 电源区域 | ${PSU_BOARD_VER} | 2 | 版本来自 Redfish；不使用 PSU 模块 BOM 近似替代 |"
} > "${OUT_DIR}/board_info_zh.md"

{
  echo "# 基准配置填写_部件信息"
  echo
  echo "| 类别 | 物料号 | 批次号 | 物料描述 | Firmware | Driver | 位置 | 数量 | 备注 |"
  echo "|---|---|---|---|---|---|---|---:|---|"
  echo "| CPU |  |  | ${CPU_MODEL:-N/A} |  |  | CPU Socket | ${CPU_SOCKETS:-N/A} | CPU 型号以当前环境识别为准；未找到可直接对应的 BOM CPU 行 |"
  echo "| MEM | ${MEM_BOM_PN:-} | ${MEM_BOM_BATCH:-} | ${MEM_BOM_DESC:-${MEM_VENDOR:-N/A} Memory} |  |  | DIMM | ${DIMM_COUNT} | 总容量 ${MEM_TOTAL}；BOM 仅补单条料号信息 |"
  awk '
    /^#/ || NF==0 {next}
    /NAME="nvme[0-9]+n[0-9]+"/ {
      name=model=serial=size=""
      if (match($0, /NAME="[^"]*"/))   {name=substr($0, RSTART+6, RLENGTH-7)}
      if (match($0, /MODEL="[^"]*"/))  {model=substr($0, RSTART+7, RLENGTH-8)}
      if (match($0, /SERIAL="[^"]*"/)) {serial=substr($0, RSTART+8, RLENGTH-9)}
      if (match($0, /SIZE="[^"]*"/))   {size=substr($0, RSTART+6, RLENGTH-7)}
      printf("| NVMe SSD |  |  | %s |  | nvme | PCIe/NVMe | 1 | /dev/%s %s %s |\n", model, name, serial, size)
    }
  ' "${RAW_DIR}/lsblk.txt"
  if [[ -n "${RAID_SUMMARY_ROWS}" ]]; then
    printf "%s\n" "${RAID_SUMMARY_ROWS}" | awk -F'|' -v pn="${RAID_BOM_PN:-}" -v batch="${RAID_BOM_BATCH:-}" -v desc_map="${RAID_BOM_DESC:-}" '
      NF >= 4 {
        desc=$3; qty=$4
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", desc)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", qty)
        if (desc ~ /SP686C/ && desc_map != "") {
          printf("| RAID | %s | %s | %s |  |  | PCIe | %s | 当前环境检测到 RAID；BOM 补料号 |\n", pn, batch, desc_map, qty)
        } else {
          printf("| RAID |  |  | %s |  |  | PCIe | %s | 仅按当前环境汇总 |\n", desc, qty)
        }
      }'
  fi
  if [[ -n "${NIC_PHYSICAL_ROWS_ZH}" ]]; then
    printf "%s\n" "${NIC_PHYSICAL_ROWS_ZH}"
  elif [[ -n "${NIC_SUMMARY_ROWS}" ]]; then
    printf "%s\n" "${NIC_SUMMARY_ROWS}" | awk -F'|' '
      NF >= 4 {
        desc=$3; qty=$4
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", desc)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", qty)
        printf("| NIC |  |  | %s |  |  | PCIe/OCP | %s | 当前环境汇总；未做强制 BOM 映射 |\n", desc, qty)
      }'
  fi
} > "${OUT_DIR}/component_info_zh.md"

{
  echo "# 固件清单"
  echo
  echo "| 类别 | 名称 | 版本 |"
  echo "|---|---|---|"
  if [[ -n "${FIRMWARE_SUMMARY_ROWS}" ]]; then
    printf "%b" "${FIRMWARE_SUMMARY_ROWS}" | awk -F'|' '
      NF >= 4 {
        id=$2; name=$3; ver=$4
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", ver)
        printf("| %s | %s | %s |\n", id, name, ver)
      }'
  else
    echo "| N/A | 未采集到固件清单 | N/A |"
  fi
} > "${OUT_DIR}/firmware_inventory_zh.md"

{
  echo "# 基准配置汇总"
  echo
  echo "## 软件信息"
  awk 'NR==1 && /^#/ {next} {print}' "${OUT_DIR}/software_info_zh.md"
  echo
  echo "## 板卡信息"
  awk 'NR==1 && /^#/ {next} {print}' "${OUT_DIR}/board_info_zh.md"
  echo
  echo "## 部件信息"
  awk 'NR==1 && /^#/ {next} {print}' "${OUT_DIR}/component_info_zh.md"
  echo
  echo "## 固件清单"
  awk 'NR==1 && /^#/ {next} {print}' "${OUT_DIR}/firmware_inventory_zh.md"
} > "${OUT_DIR}/final_baseline_template_zh.md"

markdown_table_to_html "${OUT_DIR}/software_info_zh.md" "基准配置填写_软件信息" "${OUT_DIR}/software_info_zh.html"
markdown_table_to_html "${OUT_DIR}/board_info_zh.md" "基准配置填写_板卡信息" "${OUT_DIR}/board_info_zh.html"
markdown_table_to_html "${OUT_DIR}/component_info_zh.md" "基准配置填写_部件信息" "${OUT_DIR}/component_info_zh.html"
markdown_table_to_html "${OUT_DIR}/firmware_inventory_zh.md" "固件清单" "${OUT_DIR}/firmware_inventory_zh.html"
cp -f "${OUT_DIR}/software_info_zh.html" "${OUT_DIR}/基准配置填写_软件信息.html"
cp -f "${OUT_DIR}/board_info_zh.html" "${OUT_DIR}/基准配置填写_板卡信息.html"
cp -f "${OUT_DIR}/component_info_zh.html" "${OUT_DIR}/基准配置填写_部件信息.html"

{
  echo '<!DOCTYPE html>'
  echo '<html lang="zh-CN">'
  echo '<head>'
  echo '  <meta charset="UTF-8">'
  echo '  <title>基准配置汇总</title>'
  echo '  <style>'
  echo '    body { font-family: "Microsoft YaHei", "PingFang SC", Arial, sans-serif; margin: 12px; color: #333; background: #fff; }'
  echo '    h1 { font-size: 20px; margin: 0 0 12px; }'
  echo '    h2 { font-size: 16px; margin: 22px 0 8px; }'
  echo '    table { border-collapse: collapse; width: 100%; table-layout: auto; margin-bottom: 18px; }'
  echo '    th, td { border: 1px solid #cfd6df; padding: 8px 10px; font-size: 14px; vertical-align: top; word-break: break-word; }'
  echo '    th { background: #eef2f6; font-weight: 700; text-align: left; }'
  echo '    tr:nth-child(even) td { background: #fafbfd; }'
  echo '    .wrap { max-width: 1600px; }'
  echo '  </style>'
  echo '</head>'
  echo '<body>'
  echo '  <div class="wrap">'
  echo '    <h1>基准配置汇总</h1>'
  for section in software_info_zh board_info_zh component_info_zh firmware_inventory_zh; do
    case "${section}" in
      software_info_zh) title="软件信息" ;;
      board_info_zh) title="板卡信息" ;;
      component_info_zh) title="部件信息" ;;
      firmware_inventory_zh) title="固件清单" ;;
    esac
    echo "    <h2>${title}</h2>"
    awk '
      function esc(s) {
        gsub(/&/, "\\&amp;", s); gsub(/</, "\\&lt;", s); gsub(/>/, "\\&gt;", s); return s
      }
      BEGIN { row=0; print "    <table>" }
      /^\|/ {
        line=$0
        gsub(/\r/, "", line)
        if (line ~ /^\|---/) next
        sub(/^\|/, "", line); sub(/\|$/, "", line)
        n=split(line, a, /\|/); row++
        if (row == 1) {
          print "      <thead><tr>"
          for (i=1; i<=n; i++) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", a[i]); printf "        <th>%s</th>\n", esc(a[i]) }
          print "      </tr></thead>"; print "      <tbody>"
        } else {
          print "      <tr>"
          for (i=1; i<=n; i++) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", a[i]); printf "        <td>%s</td>\n", esc(a[i]) }
          print "      </tr>"
        }
      }
      END { if (row >= 1) print "      </tbody>"; print "    </table>" }
    ' "${OUT_DIR}/${section}.md"
  done
  echo '  </div>'
  echo '</body>'
  echo '</html>'
} > "${OUT_DIR}/final_baseline_template_zh.html"

log "DONE" "Generated files:"
for f in \
  "${OUT_DIR}/software_info.md" \
  "${OUT_DIR}/tools_info.md" \
  "${OUT_DIR}/component_spec.md" \
  "${OUT_DIR}/component_info_prefill.md" \
  "${OUT_DIR}/board_info_prefill.md" \
  "${OUT_DIR}/firmware_inventory.md" \
  "${OUT_DIR}/pcie_device_summary.md" \
  "${OUT_DIR}/final_baseline_template.md" \
  "${OUT_DIR}/software_info_zh.md" \
  "${OUT_DIR}/board_info_zh.md" \
  "${OUT_DIR}/component_info_zh.md" \
  "${OUT_DIR}/firmware_inventory_zh.md" \
  "${OUT_DIR}/final_baseline_template_zh.md" \
  "${OUT_DIR}/software_info_zh.html" \
  "${OUT_DIR}/board_info_zh.html" \
  "${OUT_DIR}/component_info_zh.html" \
  "${OUT_DIR}/firmware_inventory_zh.html" \
  "${OUT_DIR}/pcie_device_summary.html" \
  "${OUT_DIR}/基准配置填写_软件信息.html" \
  "${OUT_DIR}/基准配置填写_板卡信息.html" \
  "${OUT_DIR}/基准配置填写_部件信息.html" \
  "${OUT_DIR}/final_baseline_template_zh.html" \
  "${RAW_DIR}/"; do
  log "DONE" "  - ${f}"
done
