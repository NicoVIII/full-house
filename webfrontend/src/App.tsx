import type { RouteSectionProps } from "@solidjs/router";
import Container from "@suid/material/Container";
import "./styles.css";
import { FullHouseAppBar } from "./components/AppBar";

const App = (props: Readonly<RouteSectionProps>) => {
	return (
		<>
			<FullHouseAppBar />
			<Container maxWidth="md" sx={{ py: 6 }}>
				{props.children}
			</Container>
		</>
	);
};

export default App;
