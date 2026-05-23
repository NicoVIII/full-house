import { A } from "@solidjs/router";
import HomeIcon from "@suid/icons-material/Home";
import AppBar from "@suid/material/AppBar";
import Box from "@suid/material/Box";
import Button from "@suid/material/Button";
import Toolbar from "@suid/material/Toolbar";
import Typography from "@suid/material/Typography";
import { For } from "solid-js";
import { mainRoutes } from "../routes";

export function FullHouseAppBar() {
	return (
		<AppBar position="sticky">
			<Toolbar>
				<HomeIcon sx={{ mr: 1 }} />
				<Typography variant="h6" component="div" sx={{ mr: 2 }}>
					Full House
				</Typography>
				<Box sx={{ flexGrow: 1, display: { xs: "flex" } }}>
					<For each={mainRoutes}>
						{({ name, build }) => (
							<Button
								component={A}
								href={build()}
								sx={{ my: 2, color: "white", display: "block" }}
							>
								{name}
							</Button>
						)}
					</For>
				</Box>
			</Toolbar>
		</AppBar>
	);
}
