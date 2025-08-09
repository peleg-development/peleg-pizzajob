# 🚀 Installation Guide

## Quick Start

1. **Download** the resource to your server's `resources` folder
2. **Add** to your `server.cfg`: `ensure peleg-pizzajob`
3. **Restart** your server

## Dependencies

### Required
- **ox_lib** - Modern UI library
- **es_extended** OR **qb-core** - Framework (auto-detected)

### Optional
- **ox_target** - For target interactions (recommended)
- **qb-target** - Alternative target system

## Configuration

### Basic Setup
1. Open `shared/config.lua`
2. Configure your job location: `Config.JobStartLocation`
3. Set your preferred target system: `Config.Target`
4. Adjust payout settings as needed

### Framework Detection
The resource automatically detects your framework:
- **ESX**: Detects `es_extended` resource
- **QB-Core**: Detects `qb-core` resource

No manual framework configuration needed!

## Items Required

Add this item to your items database:
```sql
INSERT INTO items (name, label, weight) VALUES ('pizza_delivery_box', 'Pizza Box', 1);
```

## Metadata Setup

### QB-Core
Add to `qb-core/server/player.lua`:
```lua
PlayerData.metadata['pizzaexp'] = PlayerData.metadata['pizzaexp'] or 0
```

### ESX
No additional setup required - metadata is handled automatically.

## Testing

1. **Start** the resource
2. **Go to** the job location (default: `294.5, -964.09, 29.42`)
3. **Interact** with the NPC
4. **Test** the vehicle garage and job system

## Troubleshooting

### Common Issues

**Resource won't start:**
- Check that ox_lib is installed and started
- Verify your framework (es_extended or qb-core) is running

**NPC not appearing:**
- Check the coordinates in `Config.JobStartLocation`
- Ensure the NPC model exists

**Target system not working:**
- Verify ox_target or qb-target is installed
- Check `Config.Target` setting

**Vehicles not spawning:**
- Ensure vehicle models are in the `stream` folder
- Check vehicle metadata files are present

### Debug Mode

Enable debug mode in config:
```lua
Config.Debug = true
```

This will show detailed console logs for troubleshooting.

## Support

If you encounter issues:
1. Check the console for error messages
2. Enable debug mode for detailed logging
3. Verify all dependencies are installed
4. Check the configuration examples

---

**Need help?** Open an issue on GitHub or join our Discord! 