"""配置加载器：合并 template + model_override + CLI 参数"""

from pathlib import Path
from typing import Any

import yaml

_BASE_DIR = Path(__file__).parent.parent / "config"


class ConfigLoader:
    """加载并合并 YAML 配置，支持 dot-path 查询。"""

    def __init__(self, model_name: str = "default", runtime_overrides: dict | None = None):
        self._template = self._load_yaml(_BASE_DIR / "bmc_models" / "template.yaml")
        self._settings = self._load_yaml(_BASE_DIR / "settings.yaml")
        model_path = _BASE_DIR / "bmc_models" / f"model_{model_name}.yaml"
        self._model = self._load_yaml(model_path) if model_path.exists() else {}
        self._overrides = runtime_overrides or {}

        # deep merge: settings <- template <- model <- overrides
        self._merged = self._deep_merge(self._settings, self._template)
        self._merged = self._deep_merge(self._merged, self._model)
        self._merged = self._deep_merge(self._merged, self._overrides)

    @staticmethod
    def _load_yaml(path: Path) -> dict:
        with open(path, "r", encoding="utf-8") as f:
            return yaml.safe_load(f) or {}

    @staticmethod
    def _deep_merge(base: dict, override: dict) -> dict:
        result = base.copy()
        for key, value in override.items():
            if key in result and isinstance(result[key], dict) and isinstance(value, dict):
                result[key] = ConfigLoader._deep_merge(result[key], value)
            else:
                result[key] = value
        return result

    def get(self, dot_path: str, default: Any = None) -> Any:
        """通过点分路径获取值，如 'login.username_selector'。"""
        keys = dot_path.split(".")
        node = self._merged
        for key in keys:
            if isinstance(node, dict) and key in node:
                node = node[key]
            else:
                return default
        return node

    @property
    def settings(self) -> dict:
        """全局设置（合并后完整配置）。"""
        return self._merged

    def resolve_url(self, ip: str | None = None) -> str:
        """构建 BMC URL，替换 {ip} 占位符。"""
        pattern = self.get("bmc.url_pattern")
        target_ip = ip or self.get("bmc.default_ip")
        return pattern.format(ip=target_ip)
