# DjVu Preview Plugin for Yazi

A Yazi plugin to preview DjVu files.

## Requirements

- `ddjvu` ([DjVuLibre](https://github.com/DjVuLibre/djvulibre))
- [Yazi](https://github.com/sxyazi/yazi)

## Installation
1. Copy the main.lua to  `~/.config/yazi/plugins/djvu-view.yazi`.
Use the tools to do it if you prefer.
```bash
git clone https://github.com/Shallow-Seek/djvu-view.yazi ~/.config/yazi/plugins/djvu-view.yazi
```
or
```bash
ya pkg add Shallow-Seek/djvu-view
 ```

2. Add the following in your `~/.config/yazi/yazi.toml`:

```toml
[[plugin.prepend_previewers]]
name = "*.{djvu,djv}"
run  = "djvu-view"
```

## Usage

Once installed, the plugin will automatically handle DjVu file previews when you navigate to them in Yazi.

## Credits

[Yazi](https://github.com/sxyazi/yazi)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
