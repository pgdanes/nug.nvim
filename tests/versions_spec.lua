describe("version resolving works", function()
    local version = require("version")
    local test_data = {
        versions = {
            "1.0.0",
            "0.3.0",
            "0.2.1",
            "0.2.0",
            "0.1.0"
        }
    }
    it("should resolve latest version for major request", function()
        local result = version.resolve_version(test_data.versions, "0.1.0", "major")
        if result == nil then
            assert(false, "could not resolve version")
        else
            assert.equals(result.major, 1)
            assert.equals(result.minor, 0)
            assert.equals(result.patch, 0)
        end
    end)

    it("should resolve latest minor for minor request", function()
        local result = version.resolve_version(test_data.versions, "0.2.0", "minor")

        if result == nil then
            assert(false, "could not resolve version")
        else
            assert.equals(result.major, 0)
            assert.equals(result.minor, 3)
            assert.equals(result.patch, 0)
        end
    end)

    it("should resolve latest patch for patch request", function()
        local result = version.resolve_version(test_data.versions, "0.2.0", "patch")

        if result == nil then
            assert(false, "could not resolve version")
        else
            assert.equals(result.major, 0)
            assert.equals(result.minor, 2)
            assert.equals(result.patch, 1)
        end
    end)
end)
