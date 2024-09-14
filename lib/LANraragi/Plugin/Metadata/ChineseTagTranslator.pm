package LANraragi::Plugin::Metadata::ChineseTagTranslator;

use strict;
use warnings;
use utf8;  # 使脚本支持 UTF-8 编码
use Encode qw(decode encode);
use Mojo::JSON qw(from_json);
use Mojo::UserAgent;
use LANraragi::Utils::Logging qw(get_plugin_logger);

# Meta-information about your plugin
sub plugin_info {
    return (
        name        => "ChineseTagTranslator",
        type        => "metadata",
        namespace   => "entagtocntag",
        author      => "Aki",
        version     => "1.0",
        description => "利用EhTagTranslation项目的数据库，将英文Tag翻译为中文Tag.",
        icon =>
          "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMgAAADICAYAAACtWK6eAAAhdklEQVR4nOydCXgURdrH/33MJIRwRhBJIgi6qIhAQiTcIiiwgKyg6IeKgqKIyCrgAro8sgosCmgQBRXxABGEBeUSkUNYRGHFRQ7lkHPFgAKBHOTO9Pd0JcHJMVU9ma7unpn6Pc88ZDJvT71k+p2qt+o9VPiPDKADgGQAbQDcAKAhgOoAXACUKrxnOOABsA/AYgCzAOTarZDAXHRjGgHgNABNPAJ6vGb3hykwD31WeBLASQfcWKHyyAHQyO4PVhA4+qzxLwfcUKH4eMnuD1cQGLcAOOCAGylUH78Jfy14aQbgnANuolB/dLT7gxbQkSv5XRKA7QBibNAn3OhutwICOuUNRPc53hfGYRld7VZAQEfy+llfD38CYIDhi+vHw9W2N5RGzSHVjIHkjuCjZZBSsGcr8j99nSbiARAL4Ix1Wgn8wdtAngJA/TRLUZP7IPKeMVCad4AkV7ZKE+honiKkD6gPXEqnib0JYKR1Wgn8odRA9KXVUQBXU6VlGdVGzkZEn8ctUS4UuPTSvSjYtpwmkgugpj7hWKeVwCilX/+PMY1DcSHq+cXCOPxEbd2NJRIJoLM12gj8RS55TGQJVnsyBe5Oht0TQQlqgqGNKrGb5VB042gPoAFNSG3bW8wcVURp2ATK9W1ZYndYo43AX0ojc6lE3D3aGm1ClIh+I1giCQCutUYbgT/oBtKaJiDVi4faopN1GoUgrnZ9gWrRLLGHrdFG4A+6gdxIE3C1/bPYyg0QKaomOS9i8CQAphUJrEW/86+kCShNbrZOmxBGTWDuZtUuSUITOAi5ZA/eJ1L1WtZpE8KoibcbEevFXxOBP8gl+/A+kSKqWadNCKPUi4fc+CaWWA9rtBEYRTgXFqK2ZsYm3gAgzhptBEYQBmIhrjbMCUL/PJjOisA6hIFYiNq8A1CtBktMLLMchDAQC5GiasDd5R6WmDhVdxDCQCzG3ZcZshMDoI812ghYCAOxGPW6RCjXJbDEnrdGGwELYSA2oLZgRrcni90sZyAMxAbUJEN+eE/+mghYCAOxAbX1bYCLej4LYSDOQBiIDUiyAvefH2GJdS0p+yqwEWEgNhFx5xMskboA+lujjcAXwkBsQom/HvLVN7DEhlmjjcAXwkBshPgidLqx0hEEfBEGYiOuJEPR7cJZtxFhIDaiJtwGqQ5zgmDGpgj4IQzERiTVDfftD7HEbmXl7Aj4IQzEZty9hgAytU1IdQB3W6eRwJuqNPEUmIgSex3JNPQc20MTmys6UvlFLoCLAA4C2AJgfVULhAsDcQCuxO7IoxtItKh4UiWSvcop7QPwJYBFAHYbfQOxxHIABsuTCgKjBYAxAP4LYLXRJqrCQByA2ry9qB5jLX1KZhRmvA/3JVbRL4eQtyIFnl8Ok7Z8Us0YeNLPAUWFxQKFXlX/PUWAx3P5qVbk9Zq3nOb543oiV1T8OzJgIaBpXtfle11WRHaOpOg6kBvdAHfne+Dufr/J/2P/kSKrw91/FPIWCjfDQmoAeBfAEwAGA/ipMiGppJmkT6pPWg5X+35V0qDozAlkPZEIjd5AxlbUNneg+uTVJIDQTjxnTyHj/sa26hDG/AqgTWWOPNclVs6sJx1tHDqFu75E3rKZdqsBuV4clGZJdqsRrsQC2AWgQuEybgbiybqIwu/X83p7U8n77A27VSCoSSKqxEZ0I1lY/pfcfBDt3K+83tp0tPOp8Jz9BXK9eFv1cLXuhryP6H5Iv3790Ls3sxB2WJOfn4+0tDTs2bMHmzdvxoULF4xe2grAYgCDSl0Pfgbi8KVVeTxnTthuIErzdkBEFJCXTZUbNkxEwRslIyMD77zzDqZMmYKLFy8aueQ+AEsArARXH6QwuHpSajlZdqtANgrUVrdSZTZt2oTCwkLLdAp2atasibFjx2L37t3o399w/tlzpT9wMxDNa3s1KHBIkW5WH5GsrCx8/fXXlukTKjRu3BjLly/HyJGGOm7foq9mIWaQElwRjumDorakzyA6+rpaUDWmT5+OBx54wIjoeDKpc9PEEzzLgIj/Gw+5Rl271SAo8c2gtqJXgV+2bJll+oQakZGRWLhwIW6/ndmvJRlAW35LrCLnG4hUoy6ixs5H5KDn7FalDO4e9HaFBw8exJEjRyzTJxTR/RIDdOEXamLAkVRb3wa5wTWA6r78O0n1qnQjK0Bpf0Tys1K5nOL9s/LHxCgrf/RX1H+nqOT9pKgakK9qCqXRjeRnp+Hqeh/wxiiAshP46quvYs6cOZbqFUp0794dcXFxOHXqFE3sFn4GYmCJ5e47HO6OorJNeSRZIb1ECrYu9Skzb948pKSkwO12W6pbqCDLMjp37oyPP/6YJnatrU66pIh0FF+wKp4UFhZiy5YtlukTiiQmJrJE4jhu8xrYxZKFgfjCZSBHZMOGDZboEqroSywGtTjuYnnYMqqorOkLuUFjKDe2o8oIAwmMatWYZ18KRwMpYopIqlg/04joO5z6+p49e8RuVgDIMvv25+iDGDhJlyRuw4cCrg5/ARiZhm+//bZl+oQj9vogrghew4cEUmR1uG6hV1/UDSQzM9MyncINe0NNDExx4Y4rkX7iqxvH9u3bLdMn3OB3h2psJ134IGyU1rcxv0i+/PJLy/QJN2x10sUuFhulXjwzgPHzzz+3TJ9ww+ZzEHsLJQQL7t70BKnDhw/jxx9/tEyfcMLeXSxxkm4IV4e7qHWzNE3D3LlzLdUpXOBnIAaieUWoiTH0vxMr9GTx4sW4dOmSZTqFCxzD3Q34IMJADOPqNID6elpaGtavD44qMsGEzU662MUyisrY7oXYzeKCrT6IJHaxDCPXjIGaTM9XFwZiPvYeFAoD8YuIvvTW0cePH8eJEycs0ycc4OeDGMlJF7FYfqEvs6QaMVQZ4YeYi627WMJJ9w9SNyuhG1VGLLPMhWPKLTvUJOe1P8K5NU9R2fAU7zYG5GfvtgjlZCu0RijZICjNP4+/Hq6knlBv7hzY/8kBqIxU3E2bNpHSmyIV1xw4Fm1gO+n5GxZwG74sq5D3ySuoNvJ1RNw5wqIx+eBK6oEcyuvp6elYsWIF7rvvPgu1Cl3sDTWxmJw5zyB/+0q71QgIuW4DyFffQJV56623LNMn1LHXB7EaTxGyX3mYtGYIZlyd6V2ht27dip9+qrRhEhd+//13TJw4ES1btkRsbCy6dOmCdevWWTY+T8LLQHRyMlF06Du7tQgIFyPsRGfjxo2W6KIzcOBATJ48GXv37kVqair+/e9/o0+fPvjss88s04EXHJdYDjUQfSJJPWq3CgGh3NgOUp0rqTJWbfempKSQGas8Ho8HgwcPJrNLMBOWtXmDrXdJeSRFhbsnvUHrli1bkJuby12XRYsW+XwtMzMT27Zt464DT8KyursTy436i7vHQ9R8muzsbOrNaxb6kopGVpb9fVcCwd5gRZtQrkuwW4WAURo2hdy4Qs/JMsybN4+7Hh7GeZemUZsoO56wq+7u6nw3lGa32K2GKbiSelBf37lzJ4nPElQdjifpzptB3L0eQdQzxXWkPGdPoejID9DyzEsyklyRUFt3hRRVkzzXvySKDu+C57eTpo2ho1xzE5RGzaEmdCcHoDR0Z334cHoBOoFvOJ6k030QqXotKE1bFT/xblmAclG+kgxJ8Vprl2uDUD4iWFLKtk+QatSGfEUclBuTofypuA957opZyH3nWWPlUf1EqlUP0TO/In5O1oRe8Jzkcx7hun0woka9SXqcaJlpPuU2btwoDCQAbAs1ka9pgegZm7gNTyP/ywVcjENHSz+L3MX/hNqiIzfj0CnYsABFA55GRP9RyP1wkk+5devWke6utWvX5qZLKGNbqInksjGYjnPBOi3ttDUVW3Ky4O71KFUkOzsbS5Ys4a9LiGJfNK+NBqI2bYX8I7v5vX/b3tx3yvSlldywKeQ6V0JplkSNDpgwYQJmz57NRQ/WQeDzzz9PGmdaTUxMDHr06IFnn302oMhm25x0O6sqRj4yFVp2Ogr3bqvoK+k+jdcMoy+ZSo1d95uk6JKliqJWyGfRnXRX5wGI7P9X8jxqwiLkLngB2sVzFZVw/1GXWMvNJiEwBFmGXC/eSy6ywqVyfDNEDX+VGAdROakn1UD0JZbBJvqmk5qayjwr4cW2bdvI2G+++WaV38O+cPdKPnirkGvXQ/WJvnMqvMkYfB08Z4q3St29H0O1R/9peBx313vJg0XuspnInTeu+ElEddRc6F8ojCuxO/I+esmva8KFuXPnYtCgQejQoUOVrrcv3D1Yukt5J2bxyoD0OkyTquAfKTckQ6pJT8UNVwItqmdb8WpbnXQ/KGPovBzvMmP4b4SSrMDda6i5OoUQ6elVj73jZyAFefTXI6tzG9pUvDYbypzHmEmZWapqY0TcM1bUOvZB3759q3wtxxmEHoMjBcuH6b3ZwGtZ6D1GFZdxpG5WCOTcm82NN96IoUOrPrtyMRAt10D4ho1Oul94bzZwquPlvYwLpJgeq01CuJGcnIx//etfUNWqf7Hx+Uo00iM9SAxEKzODcJpwvY0wgJlVbdUV+PAFqsxf//pXPPzww+TnpUuX4p//pO/KPfTQQ3j66aerrBOLDz74ALNmzaLKjBs3zu8iFHFxcbjiiisC1I6TgWhGWh8ES1VFbx/EimVhAGMoNyQXN/2kJIQdOHAArVoVx8BdeeWVmDFjBgoKfH+hff3113jnnXe4lBFKS0vDxx9/TJWpU6cOxo8fb1uoDJ+vxAIjBhIkDTyLrN7FqvpHIskyXG3oIfAbN24kdbN0rrrqKjz22GNU+aNHj2LOnDlV1onG4sWLcfbsWarMXXfdZWscGR8DMdIbJEi2ecv8Xzidg2ge885aWJUXPR4PNm/efPn5hAkTEBUVRb3mH//4h+m55boeRsoTlS4H7YKPk15gIBc6WJZY3rtxvA4KvfwcKcCdMlfiHUwZ7/KksbGxzPX9xYsX8d577wWkV3m++uor7N+/nyrToUMHdOrUydRx/YXPDJLPNpBgcNIr+FLclljmOOnk8vrxUG7qSJUpXxLIyDbo3LlzkZGREZBu3rAcc0VR8Oqrr5o2XlXhM4OEipNeztCrEgZiiDLLuMCNMPL+56mv79u3Dzt27Lj8XP+mfuCBB6jX/O9//8P9998fsG468+fPx+rVq6kyAwcOxC232J8abZuTLgXDSXr5kH1eRm3yMs6VeDuzbtYbb7xR5rk+Q9SoQa/2smbNGlIcOxBOnz5taNt41KhRAY1jFpx8EAMzCOekJTPQyi8VOZ2ka0WBxWJVBqtl26pVq3DhwoXLz6Ojo/Hoo/TkKx3WuQmLlJQUZimg5ORkR8we4LeLZaS7VBDsYpXfjeNl1GWcdHPGcLWm72ZlZmbim2++KfM7I9/s+gzyn//8p0o6nTp1qsLMVRljx46F7JAvUPucdJfznfTyBsKtp6L3Us6kMdSE7kyDLl+e9Oqrr8YLL9BP4nUmTpzotz65ubnEz8nOzqbKJSQkoHdvei9GK+GzxDJgIN4ZdU6lwna1ZEWoiTljyDFXMWOzKutGNWnSJDRp0oR53UcffeSXPkuWLKm0hq83+qzxySefIDLSOV+efD5xQy2gg2AXy6Jt3jJF9kwcw92XXu7n8OHD+OGHHyr8fvz48cz3HjFiBI4cOWJIj4sXL5Lq7ywefvhhXHvttYbe0yr4GIiRYEWX82cQO3axzFzGudrdSfLofQ+r4d13363w+6FDhyI+Pp763roPY+Sm1xk+fDgJWaGhqiqee+45Q+9nJfYtsYKggWeF/we3JVYBlzEkRS32RSgsXrwYly6VTU9QFIVUI2GhL7PWrl1LlVmxYgVZNrGYNm0amjZtypSzGk5OOiObMFic9HIzocTLqDnGe7k69ae+npaWVmk3qGHDhuHuu+mdrIqKikgwofehozcnTpwwVNVRf48xY8Yw5eyAzwxipHB1EISa2HJQaPIYrBkEPrpR6Q7zwoULUa9ePeq1BQUFlW4P5+fno2fPnsxoXX1pNXXqVKaOdsHJBzEwgwSBgVTYxeLlpJsYi1Uekorb/k6qzBdffFHp7yMjIzFlyhTmGDt37iQF2rzRb/pDhw4xr50+fTquv/56ppxd2OakB4MPUuE8h1tGoVfKLQc/J6I3Pefj5MmTPpdJusPetm1b5hgzZsy43JPw+PHjhmaFLl26cM1WNAP7ctKDIB9EK79dza1og/kHhd6oJDarAVXGV7Md3WFfvnw5GjSgX68zevRo/Prrrxg5ciQ1S1HH5XLhlVforRucgG056QVff1rhG7rCrlE5Z58sRbxL5OjPvW6uCtfrvpD+UFRI0XVIxXW1hR/5BeWddAtCTXggyQqpeFKw1Xc1yQULFpCAxcpSa2NjY/Hiiy8ysw/1mUNfLhlpu/bggw86Jt6Khm056dlTzQmd9hf5qiaIeGAiIm5/kC1c/v/Bq6qJd8NTTjFq6i09qQZSWFiIDRs2+AzzGDJkCAlwXLNmDXUcI8bRsGFDcmIfDNgWi2UXntPHkDN9CHIW/IMpW6F8Kq+EqaIi7mO42vcDFLqB60spX6iqSnwM3W8IBN04vv32W+ZBpFPgFGrCpzmNmeR99BKKzpygC5U3ECtSbgOo4URDrl4Lri73UGVYvdV1f8RIHjmNKVOmkKDIYIGPk25i3z+eFO5mJP+U84G4lf3huM3rjbsXvbd6amoq6a9OQ/cxjMRqVcbQoUMxePDgKl1rF/Zt8zoAz4kf/buAmw/itcTimCfjatmFmWlYWWxWeSZPnozExES/xm7fvj1JtXVKnodRgktbk/Fk0ZvKGKrOYooi1i1JXW3/TH196dKlZTINK0Nfaq1cuRK1avkOhCzPjBkzDMs6CT4GEgSn5DASOVt+s4HXt3sZH4RvGoDKKAtUUFBAdrNYzJ4926+2AqwKik6Fi4HIcc4NHfBGvpqhZ/nlgBWxWJy/XEgSFcPPYRVmmDZtGl5++WW/xn3zzTdJhLAnCDZwvOFiIO7O9AhSR6CocHeiR6vKDa7544krAnI0nxKYUs0/iixLtQIvuExDrl0PSpOWVJnKghdL2b59u6FQ+PJomkbCT1577TW/r7UTLgaiNL4JakfnGol+41efvJoUWaOhJvW8bCRuRjxTILhuLd5+lerHw5XUi9s4paiJ9AjfY8eOVZotuGPHDlKvKpBZQDeuQJpqWo2kGzdNoPqk5cWHTH6iFeYjf+NHKPx+AzxpZ4BLGdDyc8qcJUjeB1eyVDbWyWs5U6Yjrr7s8V4ieD+XlbLhIKXXyTKkiCjIVzaCcl0i1NbdIBnMiSd1c/NzuNfxIvFr7mr8wlm8KPz5v8h6kh7moX/bT5gw4fLzDz/8kOSIsGKsjDJixAjbDWXt2rXo06cPVYZbSK1+U0f0HEoewQy5YS0ocmdlIT31ugRIV8RCO/erTxl9mVVqIJ999pmpxqEzZ84c0v3pySefNO09eRDW27zhTASjoIO+nDp//jw5FxkwYIAh46hfvz6pXNK+fXtDOowZM4YUknOy4y4MJExx9xhCzW/Jzs7Gvffei8cff9zQDayqKslA7Ny5MzlLMdLTIy8vD88884zh4g92IAwkTJHrNoDSLIkqs2nTJkPGUbNmTRLoeMcdxWcssbGxpFADq+9IKZMmTSKJUzk5OQa1tw5hIGEM69DQKLo/ceedZdN6dWPRl1tGisBpmkbaIQwZMsQUfcxEGEgY42Js97KIjo4mpX98tUVo06YNOUE3WilRn3W6detGshKdgjCQMEa5IZkZvEhj3rx5zJ4hd911F+kmZXS5tXnzZnTt2pVUY3QCwkDCGElW4O7p/7ImJiYGn376qeHWzMnJyaSAnNFmnD///DNuu+02HDx40G/dzEYYSJgTMeAZEkZjlPr16xPn/S9/+Ytf4/To0YP0JDSah7579240b96cNBC1E2EgYQ6pm9Xc2LmF7nOsX78eLVvSY7l8ERsb69f1Ho+H7HDdeuutti25hIEISOgNC/2m/v7779GqVauAxtKXWTt27GCWNfVm69atJBeele3IA26hJvnfrkbBhoXwnHfOjkQFJAVy7Svg7v04XEn0Bvyapwh5S2eQNF0SNyWrkGMawN1jKPNap8PqI4KSMj1/+tOfTBkvMjKS9Avp3bs3Mw++lL179xLn/fXXX8dTTz1lih5GMD1Y0ZOZhuzpQ1G4c23ZPAeHE/nwS4gcNKHS17TsDFya/H8o3FX5h+m6bRCqj1/AWUN+aB4PMu5vDO18qk+Z7t27G0qk8of09HT8/e9/J0GLmh/3St++fUnRuUBLlhoJVjR9iZW3fBYKd6wJKuPQyV3wAoqOVmwmo5Pz1lifxqFTsPlj5K2g9/12MpIsI6IPPTZr8+bNpI2amdSqVYtkJqakpPh13erVq0nran3JxxvTDaRgB72wmGPxeJC7dGaFX2tZF5G/YSHz8tzlwZUIVB53r6HUTEPdYZ4/fz6XsUeNGkUK0sXFxRm+Ji0tjTjvEydO5OrAm24gWjq93L2T8aT+XPF3GWmGuvbqyxMjFSWdily3AdTWt1Flpk6dSiow8kD3R3bv3k1KA0mSZOiarKwsEuh47bXXYubMmRUaAZmB6QYiX0VvAOlklGYV9+jlBo0AA81+lMYtyiZ2BSFqUk/q66mpqfjuu++4jX/FFVeQWertt9/267rz58+T1tHt2rUjTXvMRDcQU4PxWaX2nYpUuz4iB1XskSfJCqo99Tr9YnckIh+fzk85i2D1VgcjX90shg0bRna5WM17yrNv3z5yuLht2zbTdNENhDpnGuo36IW72yBEDnuZXy8NHrgiEDXuQ7LMqAySGXmPjxZhiopqw2fCxVieBAPKNTdBbkjvE1hZ62ge3HvvvSQ3vmPHjn5dl52dbajpj1H0xd6vABr6Eoh8dBoiB471+42LTv2Mwr1biZPrZKSadUlrAKUhu/1w4f6vUXT4+8tFraWaMVBv7gKlYfAuK8uTu2IWct/y3S8wIiICp0+fRp06dSzRJzMzk/gXKSkphutwRUVFISMjgxS4o2Fkm1c3kF0AfNaRdHUegOp/Z3cpFYQG+hda+j1XUTcmVq5cWSH/gzd79+5Fv379DPkYsiyTbEWVUQjc6DkINWSycN92Y005BSGBFF0bSvN2VBmrllne3HzzzThw4ADZ1mXll7Ro0YJpHEbRDYRawVm7cAaF/+XvmAmcgyvhdurrVjjqlaEbxosvvkjC4WkBjyNGjDBtTN1AmPEDuUuDs/CwoGqwCssdOnQIP/xQedSBFcTFxZGdqrFjx5bJMWnQoAGp3Dh0qHmlpqSSxw4A1EB9160DETX2fcMF1wTBC4nNeug6aL+d9CnTv39/akcqK9ENVtM0NGnSpNIei74w6oNoAF5kvVnBlqXIfd//mqyC4EOSZbhadaXKrFq1yjFpsc2aNSOBi/4Yh1FKDyvWAviWJZy3PAWXpg6Ch9W6TBD0qG3oIfyFhYW2+SJW4n2aZ6h6lz6TZD6RiNxlM431QxcEJay4LNjorFuJ917YOgDzAdAb2elrskvpyJ03DnmfvEL+kMo1N0OqXY978xeBtcjxzeD55ZDP19etW2epPk5hV4lfIh7iwXxs27ZNC1bWrFnD/P9VFjA1GMAZGwxTEIT4G3kbbFRmID8BSCqJ0RIIqCxZsoRLHoZT8BVyewpAdwD8cxoFQU1hYSE52Q5VaDHpBwG0ATAMgPF2poKww6rIXjswkrTxLoAEAF9YoI8gyOjSpQsaNWpktxrcMJrVdAxAr5JwlJkADnDWSxAENG3aFIsWLbJbDa74GxP8XcljLIA4AD0B3AEgHkADAHybfIcWlacvlqJGApF82k5TyT4HeNjpDaqq4r333iPlREOZQILmT5Usv941UZ9wYhaAUT5fVdzAsyeL/7WKn9cDC/syxaKiokhxhc6dO1uilp0EUeJ4yDGH+mpeBrDnY8uUQfopYPlDgIdd4mjcuHGGWx8EO8JA7OMQK1kNu+ZZo0n6L8D73YGs35iiHTt2xN/+9jdL1HICwkDsZRn11f99A5zZx1eD7PPFy6pzvmOuSklKSiL56EZbqoUCwkDsZRNT4hhbpMoU5ALvdQPO7GGKNmnShNTnrVu3Lj99HIgwEHvZzox7O7SW3+hrRhoyjtq1a2PBggWkgU64IQzEXjQAb1Aljm0u/qY3my2Tge/ZxahdLhfpR9ihQwfzdQgChIHYz/vU6paaB9j1jrkj/rAI2PSCIdFp06aRKurhijAQ+0kFsJMq8e1s80bL+BVY9USx4TF45JFHMHr0aPPGDkKEgTgDeumltCPm7GbpS7VlDwL5mUzRfv36hXyuhxGEgTgD/rtZniJg6X3A8a+YonXr1iUn5azatuGAMBBnwH83a+NE4MBKppjulH/wwQeIiYkJbLwQQRiIM9CYtcmObir2H/x+Zw+wfjzw72lM0Vq1apG6u337suOxwgVhIM5hHgBKDzcN2DnX/3fdNR/Y9nKJDdKZPn16WO9YVYYwEOdQCGAzVeL7+YZC0S9zbAuw/lmmmCRJpM7tI48wKz6FHcJAnAU9azPrTHF8lhHOHgQW9AJy2dnSAwcOJLOHHExdwSxC/EWcBbtT/1H6JEPIPg98ch9QyD6BT0hIwBtv0A/zwxlhIM7iJwCnqRKs7d6CXGBBb0MxVo0aNcKmTZtId1lB5QgDcR70/dyT24GcC75fXzcGOEU/mEdJVuCiRYvK9NcINwoK2MlhwkCcB6PgrVacGlsZB1YB/6EnKqKkh9/KlSvDNgCxlN9//50lkiEMxHl8Rd/uBXCkElfltx+LY6wMMHXqVHTvTu8iFQ4cOMAsznNGGIjzuFByJuKbnz4FirxsSF92vd0OyExlvvmjjz5KcsrDHY/Hgy++YJZ6OyAMxJnQw3dzLwA/rij+OS8LWHa/oQDExMREzJ5tYmRwELNr1y4cPEht8IySTgcCh7KfWpq/cRcNE85quLq9oTYFLVu21M6dO2d3xwHHcPfddxv5u4l1qIOZxfwAm95uyDhUVdX2799v9z3pGBYuXGjk73YWgOgI5WDuMKPBTXR0tLZ+/Xq770nH8Pnnn2uRkZFG/nZj7b4BBHR0/zAnUAOZO3eu3fekY1i8eLHmcrmM/N1SA6w6KrCIuVU1DEmStNGjR2tFRUV235e2ov//d+7cqQ0cONCfv9/lyniSvZ+/gEF8SWV9v7/NOnXqFLbbuXl5eeQQcP/+/WQr9+jRo/5cvhbAAP1t+GkoMJNvzPBFxMPQQ/8yKlP8S5yDOJ8v7VYgTLgI4EEAWd6/FAbifEK/W7/96MZxa0ltAEGQoZSEwNu9/AjVx3EA7Wl/fIGz0UrWxSJZ3HxWlfxdj9utiCAwGgLIdsC3bag8TgEYL07KQ4vXHHBjBfvjAoDn/Nk2F+cgwUMEgKcBDAHQzG5lHI6nZDfqTEnQ548AtpY44X6Vyv//AAAA///1q++Fppz7FgAAAABJRU5ErkJggg==",
    );
}

# 标签翻译函数
sub get_tags {
    my ($self, $lrr_info) = @_;

    my $logger = get_plugin_logger();
    my $ua     = $lrr_info->{user_agent};

    # 获取现有标签
    my $existing_tags = $lrr_info->{existing_tags};
    $logger->info("Existing tags: $existing_tags");

    # 存储翻译后的标签
    my @translated_tags;

    # 预定义需要翻译的 namespace 和其中文翻译
    my %namespace_translation = (
        "artist"     => "艺术家",
        "category"   => "分类",
        "character"  => "角色",
        "cosplayer"  => "Coser",
        # "date_added" => "添加时间",
        "female"     => "女性",
        "group"      => "团队",
        "language"   => "语言",
        "male"       => "男性",
        "mixed"      => "混合",
        "other"      => "其它",
        "parody"     => "原作",
        "reclass"    => "重新分类",
        "source"     => "源"
    );

    # 解析并翻译标签
    foreach my $tag (split /,(?!\s)/, $existing_tags) {
        $tag =~ s/^\s+|\s+$//g;

        if ($tag =~ /^([^:]+):(.+)$/) {
            my ($namespace, $key) = ($1, $2);

            my $translated_namespace = $namespace_translation{$namespace} || $namespace;

            # 特殊处理 category，用 reclass 作为 namespace 进行查询
            if ($namespace eq 'category') {
                $logger->info("Category tag detected, querying reclass instead.");
                $namespace = 'reclass';
            }

            # 跳过 date_added 和 source，不进行查询，直接保留原 key 值
            # if ($namespace eq 'date_added' || $namespace eq 'source') {
            if ($namespace eq 'source') {
                $logger->info("Skipping API query for $namespace, using original key.");
                push @translated_tags, "$translated_namespace:$key";
                next;
            }

            # 利用 EhTagTranslation 的API查询 key 值的中文翻译
            my $api_url = "https://ehtt.fly.dev/database/$namespace/$key?format=text.json";
            $logger->info("Querying API for translation: $api_url");

            my $res = $ua->get($api_url => {'accept' => 'application/json'})->result;

            if ($res->is_success) {
                my $json_res = from_json($res->body);
                my $translated_key = $json_res->{name} || $key;

                # 确保返回的翻译 key 值为UTF-8编码，否则将出现乱码
                $translated_key = decode('UTF-8', $translated_key);
                push @translated_tags, "$translated_namespace:$translated_key";
                $logger->info("Translated $tag to $translated_namespace:$translated_key");
            } else {
                $logger->error("Failed to fetch translation for $tag: " . $res->message);
                push @translated_tags, "$translated_namespace:$key";
            }
        } else {
            $logger->error("Invalid tag format: $tag");
        }
    }

    my $translated_tag_string = join(", ", @translated_tags);
    $logger->info("Translated tags: $translated_tag_string");

    # 确保返回数据以 UTF-8 编码
    return (tags => $translated_tag_string);
}

1;

