import { useNavigate } from "@solidjs/router";
import Box from "@suid/material/Box";
import Typography from "@suid/material/Typography";
import type { Component } from "solid-js";

import { routes } from "../../routes";
import BarcodeWorkflowPanel from "./BarcodeWorkflowPanel";
import StockPanel from "./StockPanel";
import { useBarcodeStockWorkflow } from "./use_barcode_stock_workflow";

const StockPage: Component = () => {
	const navigate = useNavigate();
	const workflow = useBarcodeStockWorkflow();

	const handleCreateFromUnknownBarcode = () => {
		const barcode = workflow.barcodeInput().trim();

		if (barcode === "") {
			return;
		}

		navigate(`${routes.catalog.build()}?barcode=${encodeURIComponent(barcode)}`);
	};

	return (
		<>
			<Box sx={{ display: "flex" }}>
				<Typography variant="h2" component="h1" sx={{ flexGrow: 1, fontWeight: 700 }}>
					Stock
				</Typography>
			</Box>
			<BarcodeWorkflowPanel
				mode={workflow.mode()}
				onChangeMode={workflow.setMode}
				barcodeInput={workflow.barcodeInput()}
				onBarcodeInputChange={workflow.setBarcodeInput}
				onLookup={workflow.handleScanSubmit}
				lookupIsPending={workflow.lookupIsPending()}
				onStartCamera={() => void workflow.startCamera()}
				onStopCamera={workflow.stopCamera}
				isCameraActive={workflow.isCameraActive()}
				onVideoRef={workflow.setVideoRef}
				cameraSupportStatus={workflow.cameraSupportStatus()}
				cameraError={workflow.cameraError()}
				scanError={workflow.scanError()}
				resolvedProduct={workflow.resolvedProduct()}
				bestBeforeDate={workflow.bestBeforeDate()}
				onBestBeforeDateChange={workflow.setBestBeforeDate}
				onAddStock={workflow.handleAddStockForResolvedProduct}
				createIsPending={workflow.createIsPending()}
				selectedBatchDate={workflow.selectedBatchDate()}
				onSelectedBatchDateChange={workflow.setSelectedBatchDate}
				visibleBatchesForResolvedProduct={workflow.visibleBatchesForResolvedProduct()}
				onRemoveStock={workflow.handleRemoveStockForResolvedProduct}
				removeIsPending={workflow.removeIsPending()}
				onCreateFromUnknownBarcode={handleCreateFromUnknownBarcode}
			/>
			<StockPanel
				error={workflow.stockQuery.error}
				hasNextPage={workflow.stockQuery.hasNextPage}
				isError={workflow.stockQuery.isError}
				isFetchingNextPage={workflow.stockQuery.isFetchingNextPage}
				isPending={workflow.stockQuery.isPending}
				isRemovingKey={workflow.removingKey()}
				onLoadMore={() => void workflow.stockQuery.fetchNextPage()}
				onRemoveOne={workflow.handleRemoveOne}
				removeError={workflow.removeError()}
				stock={workflow.stock()}
				total={workflow.total()}
			/>
		</>
	);
};

export default StockPage;
