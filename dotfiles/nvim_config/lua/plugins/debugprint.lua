return {
    "andrewferrier/debugprint.nvim",
    opts = {
        keymaps = {
            normal = {
                plain_below = "<leader>dl",
                plain_above = "<leader>dL",
                variable_below = "<leader>dp",
                variable_above = "<leader>dP",
                -- variable_below_alwaysprompt = nil,
                -- variable_above_alwaysprompt = nil,
                textobj_below = "<leader>do",
                textobj_above = "<leader>dO",
                toggle_comment_debug_prints = "<leader>dt",
                delete_debug_prints = "<leader>dd",
            },
            -- visual = {
            --     variable_below = "g?v",
            --     variable_above = "g?V",
            -- },
        },
        commands = {
            toggle_comment_debug_prints = "ToggleCommentDebugPrints",
            delete_debug_prints = "DeleteDebugPrints",
        },
        print_tag = 'gopro',
        filetypes = {
            apex = {
                left = "System.debug('",
                left_var = "System.debug('",
                right = "');",
                mid_var = "' + ",
                right_var = ");",
                -- right_var = " + '');",
            },
        }
    },
}
